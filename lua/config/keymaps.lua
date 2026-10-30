-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

local function unmap(modes, lhs)
  for _, mode in ipairs(type(modes) == "table" and modes or { modes }) do
    pcall(vim.keymap.del, mode, lhs)
  end
end

-- ── Khôi phục hành vi Vim gốc mà LazyVim đã đè ───────────────────────────────
-- j/k: gốc là di chuyển theo dòng thật (LazyVim đổi thành gj/gk)
unmap({ "n", "x" }, "j")
unmap({ "n", "x" }, "k")
unmap({ "n", "x" }, "<Down>")
unmap({ "n", "x" }, "<Up>")
-- H/L: gốc là nhảy lên đầu/cuối màn hình (LazyVim dùng để đổi buffer → dùng [b ]b)
unmap("n", "<S-h>")
unmap("n", "<S-l>")
-- n/N: gốc đi theo hướng của lần tìm kiếm cuối (/ hay ?)
unmap({ "n", "x", "o" }, "n")
unmap({ "n", "x", "o" }, "N")
-- Ctrl-h/j/k/l: dùng lệnh gốc <C-w>h/j/k/l để chuyển cửa sổ; <C-l> gốc = vẽ lại màn hình + tắt highlight
unmap("n", "<C-h>")
unmap("n", "<C-j>")
unmap("n", "<C-k>")
unmap("n", "<C-l>")
map(
  "n",
  "<C-l>",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw screen and clear search highlights" }
)
-- < > trong Visual: gốc là thụt lề rồi thoát Visual (dùng . để lặp lại)
unmap("x", "<")
unmap("x", ">")
-- <C-s> trong Insert: gốc (Neovim 0.11+) là hiện chữ ký hàm; giữ <C-s> = lưu file ở Normal/Visual
unmap({ "i", "s" }, "<C-s>")
map({ "i", "s" }, "<C-s>", function()
  vim.lsp.buf.signature_help()
end, { desc = "Signature Help (Neovim default)" })

-- ── Help / học Vim ──────────────────────────────────────────────────────────
require("custom.keyhelp").setup() -- lệnh :KeyHelp [phím | level N | docs]
-- stylua: ignore start
map("n", "<leader>hh", function() require("custom.keyhelp").pick() end, { desc = "Look up Vim keys (KeyHelp)" })
map("n", "<leader>hk", function() require("custom.keyhelp").ask() end, { desc = "Explain a key sequence..." })
map("n", "<leader>h1", function() require("custom.keyhelp").level(1) end, { desc = "Level 1 — Survival" })
map("n", "<leader>h2", function() require("custom.keyhelp").level(2) end, { desc = "Level 2 — Efficient editing" })
map("n", "<leader>h3", function() require("custom.keyhelp").level(3) end, { desc = "Level 3 — Development workflows" })
map("n", "<leader>h4", function() require("custom.keyhelp").level(4) end, { desc = "Level 4 — Advanced Vim" })
map("n", "<leader>hm", function() Snacks.picker.keymaps() end, { desc = "All active keymaps" })
map("n", "<leader>hd", function() require("custom.keyhelp").docs() end, { desc = "Configuration docs (README/KEYMAPS/WORKFLOWS)" })
map("n", "<leader>hg", function() require("custom.keyhelp").guides() end, { desc = "Learning guides (NEOVIM_GUIDES)" })
map("n", "<leader>ht", "<cmd>Tutor<cr>", { desc = ":Tutor — official interactive Vim lesson" })

-- ── Run / build / test cả project (mở trong terminal) ────────────────────────
map("n", "<leader>rr", function() require("custom.runner").run("run") end, { desc = "Run app (go run / spring-boot:run)" })
map("n", "<leader>rb", function() require("custom.runner").run("build") end, { desc = "Build project" })
map("n", "<leader>rt", function() require("custom.runner").run("test") end, { desc = "Test project" })
map("n", "<leader>rc", function() require("custom.runner").run("custom") end, { desc = "Run a custom command..." })
map("n", "<leader>rl", function() require("custom.runner").run("last") end, { desc = "Run the last command again" })
-- stylua: ignore end
