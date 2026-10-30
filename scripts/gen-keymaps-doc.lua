-- Sinh docs/KEYMAPS.md từ lua/custom/keyhelp/data.lua (cùng nguồn với :KeyHelp).
-- Chạy:  nvim --headless -l ~/.config/nvim/scripts/gen-keymaps-doc.lua
local config = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
package.path = config .. "/lua/?.lua;" .. config .. "/lua/?/init.lua;" .. package.path

local data = dofile(config .. "/lua/custom/keyhelp/data.lua")
local MODES = { n = "N", x = "V", o = "O", i = "I", c = "C", t = "T" }
local SRC = { native = "Native", plugin = "Plugin", custom = "Custom" }
local LEVELS = {
  "Level 1 — Survival",
  "Level 2 — Efficient editing",
  "Level 3 — Development workflows",
  "Level 4 — Advanced Vim",
}

local function cell(s)
  return (s:gsub("|", "\\|"))
end

-- Code span Markdown; chuỗi chứa ` thì bọc bằng `` ... `` (chuẩn CommonMark)
local function code(s)
  s = cell(s)
  local longest = 0
  for run in s:gmatch("`+") do
    longest = math.max(longest, #run)
  end
  if longest == 0 then
    return "`" .. s .. "`"
  end
  local fence = string.rep("`", longest + 1)
  return fence .. " " .. s .. " " .. fence
end

local out = {
  "# KEYMAPS — Key reference",
  "",
  "> Generated from `lua/custom/keyhelp/data.lua`, the same source used by `:KeyHelp`.",
  "> Edit the source data, then run `nvim --headless -l scripts/gen-keymaps-doc.lua`.",
  "> Verify Plugin and Custom mappings with `scripts/check-keyhelp.lua`. LSP mappings require attached Go and Java buffers.",
  "",
  "**Leader** = `Space`. **Mode:** N=Normal, V=Visual, O=Operator-pending (after `d`/`c`/`y`), I=Insert, C=Command-line, T=Terminal.",
  "The prefixes `i_`, `c_`, and `t_` mean: press the key in Insert, Command-line, or Terminal Mode.",
  "",
  "**Native** = built into Vim/Neovim. **Plugin** = provided by LazyVim or a plugin. **Custom** = added by this configuration.",
  "",
  "In Neovim: `<leader>hh` searches, `:KeyHelp e` explains a key, `<leader>h1` through `<leader>h4` open learning levels, and `<leader>hm` lists active mappings.",
  "",
  "## Restored Vim and Neovim behavior",
  "",
  "| Key | Current behavior | Previous override |",
  "|---|---|---|",
  "| `H` / `L` | Top / bottom visible text line | Buffer navigation (use `[b` / `]b`) |",
  "| `n` / `N` | Follow / reverse the last search direction | Always forward / backward |",
  "| `j` / `k` | Move by real lines | Screen-line movement with `gj` / `gk` |",
  "| `s` / `S` | Change a character / line | Flash jumps (plugin disabled) |",
  "| `f` `t` `;` `,` | Native character search within a line | Flash character search |",
  "| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | Native keys; `<C-l>` also clears search highlights | Window movement (use `<C-w>h/j/k/l`) |",
  "| `<` `>` (Visual) | Shift and leave Visual Mode; dot repeats | Keep the selection |",
  "| `grr` `grn` `gra` `gri` `grt` | Neovim LSP mappings | Blocked by the `gr` mapping with nowait |",
  "| `ga` | Show character codes | Call hierarchy prefix (use `<leader>ci` / `<leader>cI`) |",
  "| `i_<C-k>` | Enter a digraph (a character typed using two keys) | Signature help (use `i_<C-s>`) |",
  "| `i_<C-s>` | Neovim signature help | Save file (`<C-s>` still saves in Normal / Visual Mode) |",
  "",
}

for level = 1, 4 do
  out[#out + 1] = "## " .. LEVELS[level]
  local cats, order = {}, {}
  for _, e in ipairs(data) do
    if e[3] == level then
      if not cats[e[4]] then
        cats[e[4]] = {}
        order[#order + 1] = e[4]
      end
      table.insert(cats[e[4]], e)
    end
  end
  for _, cat in ipairs(order) do
    out[#out + 1] = ""
    out[#out + 1] = "### " .. cat
    out[#out + 1] = ""
    out[#out + 1] = "| Key | Action | Example | Mode | Source |"
    out[#out + 1] = "|---|---|---|---|---|"
    for _, e in ipairs(cats[cat]) do
      local modes = {}
      for m in e[2]:gmatch("[^,]+") do
        modes[#modes + 1] = MODES[m] or m
      end
      out[#out + 1] = string.format(
        "| %s | %s | %s | %s | %s |",
        code(e[1]),
        cell(e[5]),
        code(e[6]),
        table.concat(modes, ","),
        SRC[e.src or "native"]
      )
    end
  end
  out[#out + 1] = ""
end

local path = config .. "/docs/KEYMAPS.md"
vim.fn.mkdir(config .. "/docs", "p")
vim.fn.writefile(out, path)
print(string.format("Wrote %s (%d entries)", path, #data))
