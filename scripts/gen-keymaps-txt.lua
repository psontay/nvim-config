-- Sinh NEOVIM_GUIDES/15_KEYMAPS.txt từ:
--   (1) lua/custom/keyhelp/data.lua (English descriptions, examples, levels)
--   (2) keymap THỰC TẾ đang hoạt động (global + buffer có LSP nếu đặt KEYHELP_FILES)
-- Chạy:  KEYHELP_FILES="path/file.go path/File.java" \
--          nvim --headless -c "luafile ~/.config/nvim/scripts/gen-keymaps-txt.lua"
-- Không tự chạy khi mở Neovim; chạy thủ công sau khi đổi keymap (xem 14_TROUBLESHOOTING.txt).
vim.api.nvim_exec_autocmds("UIEnter", {})

local cfg = vim.fn.stdpath("config")
local data = dofile(cfg .. "/lua/custom/keyhelp/data.lua")

local function norm(k)
  k = k:gsub("^[ict]_", "")
  local ok, code = pcall(vim.keycode, k)
  return ok and vim.fn.keytrans(code) or k
end

local SRC = { native = "NATIVE", plugin = "PLUGIN", custom = "CUSTOM" }
local MODE = { n = "N", x = "V", o = "O", i = "I", c = "C", t = "T", s = "S" }
local function modes_str(m)
  local t = {}
  for x in m:gmatch("[^,]+") do
    t[#t + 1] = MODE[x] or x
  end
  return table.concat(t, ",")
end

local NOTES = {
  ["H"] = "LazyVim used H for the previous buffer. Native H is restored; use [b or ]b for buffers.",
  ["L"] = "LazyVim used L for the next buffer. Native L is restored; use [b or ]b for buffers.",
  ["n"] = "Follow the direction of the last / or ? search. Native behavior is restored.",
  ["N"] = "Reverse the direction of the last search. Native behavior is restored.",
  ["j"] = "Move by real lines; gj and gk move by screen lines.",
  ["k"] = "Same real-line behavior as j.",
  ["s"] = "Flash is disabled, so s is the native substitute command.",
  ["S"] = "Flash is disabled, so S changes the whole line.",
  ["f"] = "Native Motion; Flash is disabled.",
  ["t"] = "Native Motion; Flash is disabled.",
  ["<C-l>"] = "Redraw the screen and clear search highlights. Use Ctrl-w l to move right between windows.",
  ["<C-s>"] = "Normal/Visual: save. Insert: Neovim signature help. Terminal XOFF handling: NOT TESTED.",
  ["i_<C-s>"] = "Neovim signature help. LazyVim previously used this to save.",
  ["i_<C-k>"] = "Native digraph input. The blink.cmp override has been removed.",
  ["<Esc>"] = "Return to Normal Mode; in Normal Mode Esc clears highlights.",
  ["grr"] = "Neovim LSP mapping. The blocking LazyVim gr mapping has been removed.",
  ["grn"] = "Neovim LSP mapping; gr no longer blocks it.",
  ["gra"] = "Neovim LSP mapping; gr no longer blocks it.",
  ["gri"] = "Neovim LSP mapping; gr no longer blocks it.",
  ["grt"] = "Neovim LSP mapping; gr no longer blocks it.",
  ["ga"] = "Native character codes. Call hierarchy uses <leader>ci and <leader>cI.",
  ["<C-i>"] = "Tab and Ctrl-i send the same key code in some terminal modes.",
  ["]]"] = "Normal Mode with LSP: next reference. Go Operator-pending/Visual Mode: ftplugin section Motion.",
  ["i_<Tab>"] = "Jump between snippet fields when a snippet is active; otherwise use normal Tab behavior.",
  ["<F9>"] = "F7/F8/F9 depend on terminal and KDE shortcut settings. Konsole interaction: NOT TESTED.",
  ["<F8>"] = "See the F9 note.",
  ["<F7>"] = "See the F9 note.",
  ["<S-F8>"] = "Some terminals send F20 for Shift-F8; both are mapped.",
  ["<C-/>"] = "Some terminals send Ctrl-_ for Ctrl-/; both are mapped.",
  ["gc"] = "Neovim comment Operator.",
  ["<M-j>"] = "Alt-j/k may be intercepted by the terminal or KDE. Konsole interaction: NOT TESTED.",
  ["<leader>tT"] = "Go: all test files through neotest. Java: pick a test.",
  ["<leader>tt"] = "Go: neotest file. Java: JUnit class through nvim-jdtls.",
  ["<leader>tr"] = "Go: nearest neotest test. Java: nearest JUnit method.",
  ["<leader>td"] = "Go: neotest with Delve. Java uses its jdtls test mappings. Interactive execution: NOT TESTED.",
  ["<leader>uh"] = "Inlay hints are off by default.",
  ["<leader>cu"] = "Custom references picker with previews.",
}

-- ── thu thập keymap thật ────────────────────────────────────────────────────
vim.defer_fn(function()
  local context_errors = 0
  local live = {} ---@type table<string, {ctx:table<string,boolean>, modes:table<string,boolean>, desc:string}>
  local function add(ctx, buf)
    for _, mode in ipairs({ "n", "x", "o", "i", "t", "c", "s" }) do
      local maps = buf and vim.api.nvim_buf_get_keymap(buf, mode) or vim.api.nvim_get_keymap(mode)
      for _, m in ipairs(maps) do
        local k = vim.fn.keytrans(vim.keycode(m.lhs))
        local e = live[k] or { ctx = {}, modes = {}, desc = m.desc or m.rhs or "lua" }
        live[k] = e
        e.ctx[ctx] = true
        e.modes[mode] = true
        if m.desc then
          e.desc = m.desc
        end
      end
    end
  end
  add("global")
  local ctxnames = {}
  for file in (vim.env.KEYHELP_FILES or ""):gmatch("%S+") do
    vim.cmd.edit(vim.fn.fnameescape(file))
    local b = vim.api.nvim_get_current_buf()
    local ready = vim.wait(60000, function()
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = b })) do
        if client.initialized then
          return true
        end
      end
      return false
    end, 200)
    if not ready then
      io.stdout:write("LSP NOT READY " .. file .. "\n")
      context_errors = context_errors + 1
    end
    vim.wait(6000)
    local name = vim.bo[b].filetype
    ctxnames[#ctxnames + 1] = name
    add(name, b)
  end

  -- ── phân vào mục ──────────────────────────────────────────────────────────
  local ORDER = {
    "NORMAL MODE (native and shared keys)",
    "INSERT MODE",
    "VISUAL MODE",
    "OPERATOR-PENDING / TEXT OBJECT",
    "TERMINAL MODE",
    "COMMAND-LINE",
    "FILES, BUFFER, WINDOW, TAB, SESSION",
    "SEARCH, QUICKFIX, REPLACE",
    "LSP, DIAGNOSTICS, JAVA",
    "GIT",
    "DEBUG",
    "TESTS, RUN",
    "HELP, LEARNING",
    "OTHER",
  }
  local function section(e)
    local key, modes, cat = e[1], e[2], e[4]
    local lead = key:match("^<leader>(.)")
    if cat == "LSP" or cat == "Diagnostics" or cat == "Java" then
      return ORDER[9]
    elseif cat == "Git" then
      return ORDER[10]
    elseif cat == "Debug" then
      return ORDER[11]
    elseif cat == "Test" or cat == "Run" then
      return ORDER[12]
    elseif cat == "Learning" then
      return ORDER[13]
    elseif cat == "Terminal" then
      return ORDER[5]
    elseif cat == "Database" or cat == "Session" and not lead then
      return ORDER[14]
    elseif cat == "Quickfix" or cat == "Search" and (not lead or lead == "s" or lead == "/") then
      return ORDER[8]
    elseif cat == "Buffer" or cat == "Window" or cat == "Tab" or cat == "File" and lead then
      return ORDER[7]
    elseif lead then
      if lead == "f" or lead == "e" or lead == "," or lead == " " or lead == "b" or lead == "q" then
        return ORDER[7]
      elseif lead == "s" or lead == "x" or lead == "/" or lead == ":" then
        return ORDER[8]
      end
      return ORDER[14]
    end
    if modes:find("n") then
      return ORDER[1]
    elseif modes:find("i") then
      return ORDER[2]
    elseif modes:find("t") then
      return ORDER[5]
    elseif modes:find("c") then
      return ORDER[6]
    elseif modes:find("o") then
      return ORDER[4]
    elseif modes:find("x") then
      return ORDER[3]
    end
    return ORDER[14]
  end

  local buckets, known = {}, {}
  for _, name in ipairs(ORDER) do
    buckets[name] = {}
  end
  local missing = {}
  for _, e in ipairs(data) do
    local src = e.src or "native"
    local k = norm(e[1])
    known[k] = true
    local l = live[k]
    -- text object của mini.ai: plugin map chung `a`/`i` (x,o) rồi đọc ký tự kế tiếp
    if not l and e[2] == "x,o" and #e[1] == 2 and e[1]:find("^[ai]") then
      l = live[e[1]:sub(1, 1)]
    end
    local status
    if src ~= "native" and not e[1]:find("^[:{]") and not e[1]:find("^[ict]_") and not l then
      status = "MISSING from the current mapping snapshot"
      missing[#missing + 1] = e[1]
    elseif l and not l.ctx.global then
      status = "buffer-local (" .. table.concat(vim.tbl_keys(l.ctx), ",") .. ")"
    end
    local b = buckets[section(e)]
    b[#b + 1] = { e = e, status = status, src = src }
  end

  local lines = {}
  local function w(s)
    lines[#lines + 1] = s
  end
  local v = vim.version()
  w("================================================================")
  w("15_KEYMAPS — KEY REFERENCE")
  w("================================================================")
  w("Generated by scripts/gen-keymaps-txt.lua from KeyHelp data and active mappings.")
  w(
    string.format(
      "Versions: Neovim v%d.%d.%d, LazyVim %s, generated %s",
      v.major,
      v.minor,
      v.patch,
      tostring(LazyVim.config.version),
      os.date("%Y-%m-%d")
    )
  )
  w(
    "Buffers loaded for LSP mappings: "
      .. (#ctxnames > 0 and table.concat(ctxnames, ", ") or "(none); LSP-only mappings may be marked MISSING")
  )
  w("<leader> = Space. Modes: N=Normal V=Visual O=Operator-pending I=Insert C=Command-line T=Terminal.")
  w("Sources: NATIVE = Vim/Neovim; PLUGIN = LazyVim/plugin; CUSTOM = this configuration.")
  w("Prefixes i_, c_, t_ mean: use the key in Insert, Command-line, or Terminal Mode.")
  w("Search: <leader>hh. Explain a key: :KeyHelp <key>. All active mappings: <leader>sk or <leader>hm.")
  w("NOT TESTED means that terminal or interactive behavior still needs a manual check.")
  w("Each KeyHelp entry appears once. Check [MODE] for keys that work in several modes.")
  w("Entry format: KEY [MODE] SOURCE, action, example, and notes.")
  w("")
  w("RESTORED VIM AND NEOVIM BEHAVIOR")
  w("----------------------------------------------------------------")
  w("  H L        top / bottom visible text line; use [b and ]b for buffers")
  w("  n N        follow / reverse the last search direction")
  w("  j k        real lines; gj gk move by screen lines")
  w("  s S f t ;  native commands and Motions; Flash is disabled")
  w("  <C-l>      redraw and clear highlights; use <C-w>h/j/k/l for windows")
  w("  < >        Visual Mode: shift and leave the selection; dot repeats")
  w("  grr grn gra gri grt   native Neovim LSP mappings, no longer blocked by gr")
  w("  ga         character codes; call hierarchy uses <leader>ci and <leader>cI")
  w("  i_<C-k>    digraph input; i_<C-s> shows signature help")
  w("")
  w("TERMINAL AND KDE SHORTCUTS")
  w("----------------------------------------------------------------")
  w("  KDE can intercept Ctrl-F keys and Alt-F keys before Neovim sees them.")
  w("  Use the existing leader debug mappings if a function key does not reach Neovim.")
  w("  Check Konsole copy/paste and tab shortcuts in its profile. See 12_TERMINAL_CLIPBOARD.txt.")
  w("")

  vim.list_extend(
    lines,
    vim.split(
      [[
1. WHAT THIS REFERENCE DOES AND WHY IT HELPS
  Look up a key, its modes, source, action, and example without guessing.
2. WHEN TO USE IT
  Use this table when you remember a key or want to confirm a source.
  Use <leader>hh for interactive search and <leader>hm for active mappings.
3. HOW TO USE IT
  Search this buffer with /ciw or /rename. Read [MODE] before trying a key.
  Native commands may work without an explicit keymap entry. Plugin and
  LSP actions can require a matching filetype, attached server, or Git file.
4. IMPORTANT NOTATION
  N Normal; V Visual; O Operator-pending; I Insert; C Command-line; T Terminal.
  The i_, c_, t_ prefixes name modes. Do not type these prefixes.
5. PRACTICAL EXAMPLES
  ciw changes a word. gd goes to a definition when supported.
  <leader>tt runs a Go file's tests or a Java class's tests in their contexts.
6. COMMON MISTAKES
  Case matters: e and E differ; <leader>ci and <leader>cI differ.
  A description is not proof that an external tool or desktop shortcut works.
7. RECOVERY
  Esc cancels a pending editor command. u undoes a text change.
  For a missing mapping, inspect :messages and 14_TROUBLESHOOTING.txt.
8. MEMORY TIPS
  Learn one useful family at a time: words, windows, code, tests, or debugging.
9. PRACTICE
  Find e, ciw, and a window command in this table. Explain each source and mode.
  Try the native commands in :enew; undo afterward. Use :KeyHelp e for details.
10. ADVANCED FEATURES
  The appendix lists additional mappings from the same live collection.
  Generation is manual; changing a plugin can require a new snapshot.
11. RELATED DOCUMENTATION
  00_INDEX.txt explains learning levels and notation.
  03_EDITING.txt covers command grammar; 07_LSP_COMPLETION.txt covers code tools.
  14_TROUBLESHOOTING.txt explains checks and regeneration.
  VERIFICATION.txt records tests and limits; MANIFEST.txt records file status.

]],
      "\n",
      { plain = true }
    )
  )

  for _, name in ipairs(ORDER) do
    local items = buckets[name]
    if #items > 0 then
      w("================================================================")
      w(name .. "  (" .. #items .. " entries)")
      w("================================================================")
      for _, it in ipairs(items) do
        local e = it.e
        w(string.format("%-18s [%s]  %s", e[1], modes_str(e[2]), SRC[it.src]))
        w("    " .. e[5])
        if e[6] and e[6] ~= "" then
          w("    Example: " .. e[6])
        end
        local note = NOTES[e[1]] or NOTES[norm(e[1])]
        if note then
          w("    Note: " .. note)
        end
        if it.status then
          w("    Status: " .. it.status)
        end
        if e.help then
          w("    :help " .. e.help)
        end
      end
      w("")
    end
  end

  -- ── Phụ lục: keymap thật nhưng chưa có trong data.lua ─────────────────────
  local extra = {}
  for k, e in pairs(live) do
    local d = e.desc
    if
      not known[k]
      and not k:find("^<Plug>")
      and not k:find("^<SNR>")
      and not d:find("textobject")
      and not d:find("surrounding")
      and not d:find("action for")
      and not d:find("MiniPairs")
      and not d:find("which%-key%-trigger")
      and not d:find("Matchit")
      and not d:find("which_key_ignore")
      and not d:find("^Move to ")
      and not d:find("^:help ")
    then
      extra[#extra + 1] = { k = k, e = e }
    end
  end
  table.sort(extra, function(a, b)
    return a.k:lower() < b.k:lower()
  end)
  w("================================================================")
  w("APPENDIX — OTHER ACTIVE MAPPINGS (descriptions from Neovim and plugins)")
  w("================================================================")
  w("These mappings have no detailed KeyHelp entry. Context global means all buffers.")
  w("Auto-pair internals, which-key triggers, and text-object internals are omitted. See 03_EDITING.txt.")
  w("")
  for _, x in ipairs(extra) do
    local modes = {}
    for m in pairs(x.e.modes) do
      modes[#modes + 1] = MODE[m] or m
    end
    table.sort(modes)
    local ctx = {}
    for c in pairs(x.e.ctx) do
      ctx[#ctx + 1] = c
    end
    table.sort(ctx)
    w(
      string.format(
        "%-18s [%s]  %s   (%s)",
        (x.k:gsub("^<Space>", "<leader>")),
        table.concat(modes, ","),
        x.e.desc,
        table.concat(ctx, ",")
      )
    )
  end
  w("")
  w(
    "[End] KeyHelp entries: "
      .. #data
      .. "; appendix mappings: "
      .. #extra
      .. "; missing plugin/custom keys: "
      .. #missing
  )
  if #missing > 0 then
    w("MISSING KEYS: " .. table.concat(missing, " "))
  end
  vim.fn.writefile(lines, cfg .. "/NEOVIM_GUIDES/15_KEYMAPS.txt")
  io.stdout:write(
    string.format(
      "Wrote 15_KEYMAPS.txt: %d lines, %d entries, %d appendix mappings, %d missing\n",
      #lines,
      #data,
      #extra,
      #missing
    )
  )
  vim.cmd((#missing > 0 or context_errors > 0) and "cquit 1" or "qall!")
end, 1500)
