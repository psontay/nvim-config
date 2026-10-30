-- KeyHelp: look up Vim keys and functions in English inside Neovim.
--   :KeyHelp            search keys, descriptions, categories, and examples
--   :KeyHelp e          giải thích phím e + các phím cùng họ (E, ge, gE, w, b)
--   :KeyHelp level 2    hướng dẫn theo cấp độ 1–4
--   :KeyHelp docs       mở README / KEYMAPS / WORKFLOWS của config
-- Trong cửa sổ chi tiết: <CR> hoặc K trên một dòng → mở :help chính thức của phím đó, q để đóng.
local M = {}

local MODES = { n = "Normal", x = "Visual", o = "Operator-pending", i = "Insert", c = "Command-line", t = "Terminal" }
local SRC = { native = "Native Vim/Neovim", plugin = "Plugin/LazyVim", custom = "Custom configuration" }
local LEVELS = {
  "Level 1 — Survival: open, save, quit, move, delete, copy, paste, undo, search",
  "Level 2 — Efficient editing: Operator, Motion, Text Object, Visual Mode, buffers, windows, jump list",
  "Level 3 — Development workflows: Marks, Registers, Macros, quickfix, LSP, Git, tests, debugging",
  "Level 4 — Advanced Vim: :g, :normal, cgn, Command-line Mode, shell filters, Macros",
}
local LEVEL_TIPS = {
  "Tip: Press <Esc> when you are unsure of your mode. Use :Tutor for a 30-minute lesson.",
  "Pattern: [count] Operator [count] Motion or Text Object. Try d2w, ci(, yap, >i{. Dot repeats the change.",
  "Tip: <C-o> returns after a jump such as gd, grr, or /. which-key shows hints for prefixes such as <leader> and <C-w>.",
  "Tip: Use * then cgn and dot for repeated changes. :g/pattern/normal @q runs a Macro on matching lines.",
}

---@class KeyHelpItem
---@field key string
---@field modes string
---@field level integer
---@field cat string
---@field desc string
---@field ex string
---@field help? string
---@field rel string[]
---@field src string

---@type KeyHelpItem[]?
local items_cache

local function norm(key)
  key = key:gsub("^[ict]_", "")
  if key:find("<") then
    local ok, code = pcall(vim.keycode, key)
    if ok then
      return vim.fn.keytrans(code)
    end
  end
  return key
end

---@return KeyHelpItem[]
function M.items()
  if items_cache then
    return items_cache
  end
  items_cache = {}
  for _, e in ipairs(require("custom.keyhelp.data")) do
    items_cache[#items_cache + 1] = {
      key = e[1],
      modes = e[2],
      level = e[3],
      cat = e[4],
      desc = e[5],
      ex = e[6],
      help = e.help,
      rel = e.rel or {},
      src = e.src or "native",
    }
  end
  return items_cache
end

-- Tag :help suy ra từ phím nếu dữ liệu không ghi rõ
local function help_tag(item)
  if item.help then
    return item.help
  end
  if item.src ~= "native" then
    return nil
  end
  local key = item.key
  if key:sub(1, 1) == ":" then
    return (key:gsub("[%s{].*$", ""))
  end
  key = key:gsub("<C%-(%a)>", function(c)
    return "CTRL-" .. c:upper()
  end)
  return (key:gsub("^(CTRL%-W)(.)", "%1_%2"))
end

local function has_help(tag)
  return tag and #vim.fn.getcompletion(tag, "help") > 0
end

local function mode_names(modes)
  local out = {}
  for m in modes:gmatch("[^,]+") do
    out[#out + 1] = MODES[m] or m
  end
  return table.concat(out, ", ")
end

---@param item KeyHelpItem
local function detail_lines(item)
  local lines = {
    "# " .. item.key .. "  —  " .. item.desc,
    "",
    "- **Mode:** " .. mode_names(item.modes),
    "- **Example:** `" .. item.ex .. "`",
    "- **Source:** " .. SRC[item.src] .. "   **Category:** " .. item.cat .. "   **Level:** " .. item.level,
  }
  local tag = help_tag(item)
  if tag then
    lines[#lines + 1] = "- **Help:** `:help " .. tag .. "`"
  end
  if item.modes:find("o") then
    lines[#lines + 1] = "- Use after an Operator: d" .. item.key:gsub("^[ict]_", "") .. ", c…, y…"
  end
  return lines
end

local function by_key()
  local idx = {}
  for _, item in ipairs(M.items()) do
    local k = norm(item.key)
    idx[k] = idx[k] or {}
    table.insert(idx[k], item)
  end
  return idx
end

-- ── Cửa sổ chi tiết ─────────────────────────────────────────────────────────
---@param lines string[]
---@param tags table<integer, string> dòng → help tag
---@param title string
local function open_float(lines, tags, title)
  Snacks.win({
    text = lines,
    ft = "markdown",
    title = " " .. title .. " ",
    title_pos = "center",
    width = 0.7,
    height = math.min(#lines + 2, math.floor(vim.o.lines * 0.8)),
    border = "rounded",
    enter = true,
    fixbuf = true,
    bo = { modifiable = false },
    wo = { wrap = true, linebreak = true, conceallevel = 2, cursorline = true },
    footer = " <CR>/K: official help   /: search   q: close ",
    footer_pos = "center",
    keys = {
      q = "close",
      ["<Esc>"] = "close",
      help = {
        "<CR>",
        function(self)
          local tag = tags[vim.api.nvim_win_get_cursor(self.win)[1]]
          if tag then
            self:close()
            vim.cmd.help(tag)
          else
            vim.notify("This line has no separate help topic.", vim.log.levels.INFO)
          end
        end,
      },
      help_k = {
        "K",
        function(self)
          local tag = tags[vim.api.nvim_win_get_cursor(self.win)[1]]
          if tag then
            self:close()
            vim.cmd.help(tag)
          end
        end,
      },
    },
  })
end

-- Thử lấy mô tả từ keymap thật nếu phím không có trong dữ liệu
local function live_mapping(key)
  local found = {}
  for _, mode in ipairs({ "n", "x", "o", "i", "t" }) do
    local m = vim.fn.maparg(key, mode, false, true)
    if m and m.lhs then
      found[#found + 1] = string.format("- `%s` (%s): %s", key, MODES[mode], m.desc or m.rhs or "lua function")
    end
  end
  return found
end

--- Giải thích một phím + họ phím liên quan
---@param key string
function M.show(key)
  key = vim.trim(key or "")
  if key == "" then
    return M.pick()
  end
  local idx = by_key()
  local matches = idx[norm(key)] or {}
  local lines, tags = {}, {}
  local function add(l, tag)
    lines[#lines + 1] = l
    tags[#lines] = tag
  end

  if #matches == 0 then
    local live = live_mapping(key)
    if #live > 0 then
      add("# " .. key .. "  —  active mapping")
      add("")
      for _, l in ipairs(live) do
        add(l)
      end
    elseif has_help(key) then
      vim.cmd.help(key)
      return
    else
      vim.notify("No entry for '" .. key .. "'. Search by function in the picker.", vim.log.levels.INFO)
      return M.pick(key)
    end
    return open_float(lines, tags, "KeyHelp: " .. key)
  end

  local seen = {}
  for i, item in ipairs(matches) do
    if i > 1 then
      add("")
    end
    local tag = help_tag(item)
    for j, l in ipairs(detail_lines(item)) do
      add(l, j == 1 and tag or nil)
    end
    seen[item] = true
  end

  local related = {}
  for _, item in ipairs(matches) do
    for _, r in ipairs(item.rel) do
      for _, ri in ipairs(idx[norm(r)] or {}) do
        if not seen[ri] then
          seen[ri] = true
          related[#related + 1] = ri
        end
      end
    end
  end
  if #related > 0 then
    add("")
    add("## Related keys")
    add("")
    for _, ri in ipairs(related) do
      add(string.format("- `%s`  %s  _(example: %s)_", ri.key, ri.desc, ri.ex), help_tag(ri))
    end
  end
  open_float(lines, tags, "KeyHelp: " .. key)
end

function M.ask()
  vim.ui.input({ prompt = "Key to look up (e, ciw, gd, <C-w>v, <leader>cf): " }, function(input)
    if input and input ~= "" then
      M.show(input)
    end
  end)
end

--- Hướng dẫn theo cấp độ
---@param level integer
function M.level(level)
  level = tonumber(level) or 1
  if not LEVELS[level] then
    return vim.notify("Choose a learning level from 1 to 4.", vim.log.levels.WARN)
  end
  local lines, tags = { "# " .. LEVELS[level], "", "> " .. LEVEL_TIPS[level] }, {}
  local cats, order = {}, {}
  for _, item in ipairs(M.items()) do
    if item.level == level then
      if not cats[item.cat] then
        cats[item.cat] = {}
        order[#order + 1] = item.cat
      end
      table.insert(cats[item.cat], item)
    end
  end
  for _, cat in ipairs(order) do
    lines[#lines + 1] = ""
    lines[#lines + 1] = "## " .. cat
    for _, item in ipairs(cats[cat]) do
      lines[#lines + 1] = string.format("- `%s`  %s  _(%s)_", item.key, item.desc, item.ex)
      tags[#lines] = help_tag(item)
    end
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = "Other levels: <leader>h1 through <leader>h4   •   Search: <leader>hh"
  open_float(lines, tags, "Learn Vim — Level " .. level)
end

-- Bỏ dấu tiếng Việt để tìm được khi gõ "xoa", "xóa" hay "xoá"
local FOLD = {
  a = "àáảãạăằắẳẵặâầấẩẫậ",
  e = "èéẻẽẹêềếểễệ",
  i = "ìíỉĩị",
  o = "òóỏõọôồốổỗộơờớởỡợ",
  u = "ùúủũụưừứửữự",
  y = "ỳýỷỹỵ",
  d = "đ",
}
local fold_map
local function fold(s)
  if not fold_map then
    fold_map = {}
    for base, chars in pairs(FOLD) do
      for _, ch in ipairs(vim.fn.split(chars, "\\zs")) do
        fold_map[ch] = base
        fold_map[vim.fn.toupper(ch)] = base:upper()
      end
    end
  end
  return (s:gsub("[\192-\244][\128-\191]*", fold_map))
end

--- Picker tìm theo phím hoặc mô tả
---@param pattern? string
function M.pick(pattern)
  local entries = {}
  for _, item in ipairs(M.items()) do
    local preview = detail_lines(item)
    if #item.rel > 0 then
      preview[#preview + 1] = ""
      preview[#preview + 1] = "Related: " .. table.concat(item.rel, "  ")
    end
    local text = item.key .. " " .. item.desc .. " " .. item.cat .. " " .. item.ex
    entries[#entries + 1] = {
      text = text .. " " .. fold(text) .. " L" .. item.level,
      keylen = #item.key,
      item = item,
      preview = { text = table.concat(preview, "\n"), ft = "markdown" },
    }
  end
  Snacks.picker.pick({
    title = "KeyHelp — search by key (ciw), function (delete), or category (Window)",
    items = entries,
    pattern = pattern,
    preview = "preview",
    -- cùng điểm khớp → phím ngắn lên trước (gõ "e" thấy ngay e/E)
    sort = { fields = { "score:desc", "keylen", "idx" } },
    format = function(entry)
      local it = entry.item
      return {
        { string.format("%-14s", it.key), "Special" },
        { "L" .. it.level .. " ", "Comment" },
        { it.desc, "Normal" },
        { "  " .. it.cat .. (it.src ~= "native" and " ·" .. it.src or ""), "Comment" },
      }
    end,
    confirm = function(picker, entry)
      picker:close()
      if entry then
        vim.schedule(function()
          M.show(entry.item.key)
        end)
      end
    end,
  })
end

function M.docs()
  local dir = vim.fn.stdpath("config")
  local files = {
    { "README — structure, updates, rollback", dir .. "/README.md" },
    { "KEYMAPS — key reference", dir .. "/docs/KEYMAPS.md" },
    { "WORKFLOWS — daily Go and Java tasks", dir .. "/docs/WORKFLOWS.md" },
  }
  vim.ui.select(files, {
    prompt = "Configuration documentation",
    format_item = function(f)
      return f[1]
    end,
  }, function(choice)
    if choice then
      Snacks.win({
        file = choice[2],
        width = 0.85,
        height = 0.85,
        border = "rounded",
        enter = true,
        fixbuf = true,
        bo = { modifiable = false, readonly = true },
        wo = { wrap = true, linebreak = true, conceallevel = 2, spell = false },
        keys = { q = "close" },
        title = " " .. vim.fs.basename(choice[2]) .. "  (q: close) ",
        title_pos = "center",
        -- chỉ khoá khi xem (tránh auto-save ghi nhầm); mở lại bằng :e vẫn sửa được
        on_close = function(self)
          if self.buf and vim.api.nvim_buf_is_valid(self.buf) then
            vim.bo[self.buf].modifiable = true
            vim.bo[self.buf].readonly = false
          end
        end,
      })
    end
  end)
end

--- Bộ hướng dẫn NEOVIM_GUIDES/*.txt: picker có xem trước, <CR> mở trong buffer đọc được bằng phím Vim
function M.guides()
  local dir = vim.fn.stdpath("config") .. "/NEOVIM_GUIDES"
  if vim.fn.isdirectory(dir) == 0 then
    return vim.notify("Directory not found: " .. dir, vim.log.levels.WARN)
  end
  Snacks.picker.files({
    cwd = dir,
    ft = "txt",
    title = "NEOVIM_GUIDES — start with 00_INDEX.txt",
    hidden = false,
  })
end

M._help_tag = help_tag -- dùng cho scripts/check-keyhelp.lua

function M.setup()
  vim.api.nvim_create_user_command("KeyHelp", function(opts)
    local arg = vim.trim(opts.args)
    local lv = arg:match("^level%s*(%d)$")
    if lv then
      return M.level(tonumber(lv))
    elseif arg == "docs" then
      return M.docs()
    elseif arg == "guides" then
      return M.guides()
    end
    M.show(arg)
  end, {
    nargs = "?",
    desc = "Look up Vim keys and functions in English",
    complete = function(lead)
      local ret = { "level 1", "level 2", "level 3", "level 4", "docs", "guides" }
      for _, item in ipairs(M.items()) do
        ret[#ret + 1] = item.key
      end
      return vim.tbl_filter(function(k)
        return vim.startswith(k, lead)
      end, ret)
    end,
  })
end

return M
