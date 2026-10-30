-- Bộ ký hiệu không cần Nerd Font (hiển thị đúng với font Hack/Noto Sans Mono mặc định của Konsole).
-- Chỉ được dùng khi vim.g.nerd_font = false (xem init.lua).
local M = {}

M.diagnostics = { Error = "E ", Warn = "W ", Hint = "H ", Info = "I " }

M.git = { added = "+", modified = "~", removed = "-" }

M.dap = {
  Stopped = { "→ ", "DiagnosticWarn", "DapStoppedLine" },
  Breakpoint = "● ",
  BreakpointCondition = "◆ ",
  BreakpointRejected = { "○ ", "DiagnosticError" },
  LogPoint = "◇ ",
}

-- Kind của LSP: chữ viết tắt ngắn, đủ để phân biệt trong danh sách symbol/completion
M.kinds = {
  Array = "[] ",
  Boolean = "b ",
  Class = "C ",
  Color = "# ",
  Constant = "K ",
  Constructor = "c ",
  Control = "^ ",
  Collapsed = "▸ ",
  Enum = "E ",
  EnumMember = "e ",
  Event = "! ",
  Field = ". ",
  File = "F ",
  Folder = "/ ",
  Function = "ƒ ",
  Interface = "I ",
  Key = "k ",
  Keyword = "w ",
  Method = "m ",
  Module = "M ",
  Namespace = "N ",
  Null = "∅ ",
  Number = "n ",
  Object = "{} ",
  Operator = "± ",
  Package = "P ",
  Property = "p ",
  Reference = "& ",
  Snippet = "s ",
  String = '" ',
  Struct = "S ",
  Text = "t ",
  TypeParameter = "T ",
  Unit = "u ",
  Value = "v ",
  Variable = "x ",
}

return M
