-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Tự động ghi file khi chuyển buffer/thoát (kết hợp với auto-save.nvim)
vim.o.autowrite = true
vim.o.autowriteall = true

-- Giao diện tĩnh: không cuộn mượt, không hiệu ứng
vim.g.snacks_animate = false

-- Dấu fold ở cột trái: LazyVim dùng glyph Nerd Font
if not vim.g.nerd_font then
  vim.opt.fillchars:append({ foldopen = "▾", foldclose = "▸" })
end

-- Thụt lề theo ngôn ngữ (Go tab, Java 4 spaces...): xem autocmds.lua

-- Fedora bật debuginfod mặc định → delve tải debug-info của libc mỗi lần debug (chậm hàng chục giây).
-- Chỉ tắt cho các tiến trình con của Neovim; hệ thống/terminal ngoài giữ nguyên.
vim.env.DEBUGINFOD_URLS = nil

-- Không cần provider Perl/Node/Python cho plugin remote (không plugin nào dùng)
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- Thời gian chờ phím kế tiếp của một tổ hợp (vd gco, <leader>ff); 400ms dễ thở hơn cho người mới
vim.o.timeoutlen = 400
