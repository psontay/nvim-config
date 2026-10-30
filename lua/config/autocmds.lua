-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local function augroup(name)
  return vim.api.nvim_create_augroup("custom_" .. name, { clear = true })
end

-- ── Thụt lề theo ngôn ngữ ───────────────────────────────────────────────────
-- Đếm các dòng thụt bằng tab và bằng space trong 300 dòng đầu để đi theo style sẵn có của file
-- (vd project tạo từ start.spring.io dùng tab). .editorconfig nếu có sẽ được ưu tiên.
local function uses_tabs(buf)
  local tabs, spaces = 0, 0
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, 300, false)) do
    if line:find("^\t") then
      tabs = tabs + 1
    elseif line:find("^  ") then
      spaces = spaces + 1
    end
  end
  return tabs > spaces
end

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("indent"),
  pattern = { "go", "java", "xml", "groovy", "kotlin", "sql" },
  callback = function(ev)
    local bo = vim.bo[ev.buf]
    if ev.match == "go" then
      -- gofmt dùng tab; hiển thị rộng 4 như GoLand
      bo.tabstop = 4
      return
    end
    local ec = vim.b[ev.buf].editorconfig or {}
    if ec.indent_style or ec.indent_size then
      return
    end
    bo.tabstop = 4
    bo.shiftwidth = 4
    bo.softtabstop = 4
    bo.expandtab = not uses_tabs(ev.buf)
  end,
})

-- ── Auto-save không kích hoạt format ────────────────────────────────────────
-- auto-save.nvim ghi file liên tục khi đang gõ; nếu format chạy lúc đó, goimports sẽ xoá
-- import bạn vừa thêm. Format chỉ chạy khi bạn chủ động :w / <C-s> / <leader>cf.
vim.api.nvim_create_autocmd("User", {
  group = augroup("autosave_noformat"),
  pattern = "AutoSaveWritePre",
  callback = function(ev)
    local buf = ev.data and ev.data.saved_buffer or vim.api.nvim_get_current_buf()
    vim.b[buf].custom_autoformat_saved = vim.b[buf].autoformat
    vim.b[buf].autoformat = false
  end,
})
vim.api.nvim_create_autocmd("User", {
  group = augroup("autosave_restore_format"),
  pattern = "AutoSaveWritePost",
  callback = function(ev)
    local buf = ev.data and ev.data.saved_buffer or vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_is_valid(buf) then
      vim.b[buf].autoformat = vim.b[buf].custom_autoformat_saved
      vim.b[buf].custom_autoformat_saved = nil
    end
  end,
})

-- ── Java: không format khi lưu ──────────────────────────────────────────────
-- Formatter của jdtls (Eclipse) khác IntelliJ → format cả file khi lưu sẽ tạo diff lớn trong
-- project dùng chung. Format thủ công bằng <leader>cf (cả file) hoặc chọn vùng rồi <leader>cf.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("java_no_autoformat"),
  pattern = { "java" },
  callback = function(ev)
    vim.b[ev.buf].autoformat = false
  end,
})

-- ── Hiển thị tiến trình LSP (jdtls import project, gopls load package) trên statusline ──
vim.api.nvim_create_autocmd("LspProgress", {
  group = augroup("lsp_progress"),
  callback = function()
    vim.cmd.redrawstatus()
  end,
})
