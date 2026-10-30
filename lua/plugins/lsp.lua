-- LSP chung cho mọi ngôn ngữ
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Inlay hints gây rối mắt khi đọc code → mặc định tắt, bật/tắt bằng <leader>uh
      inlay_hints = { enabled = false },
      servers = {
        ["*"] = {
          -- stylua: ignore
          keys = {
            -- LazyVim gán `gr` (nowait) cho references → chặn mất các phím LSP gốc của Neovim:
            -- grr (references), grn (rename), gra (code action), gri (implementation), grt (type def).
            { "gr", false },
            -- `ga` gốc = xem mã ASCII/Unicode của ký tự; dời call hierarchy sang <leader>c
            { "gai", false },
            { "gao", false },
            -- <C-k> trong Insert gốc = nhập digraph; chữ ký hàm dùng <C-s> (gốc Neovim) hoặc gK
            { "<c-k>", false, mode = "i" },
            { "<leader>cu", function() Snacks.picker.lsp_references() end, desc = "Find Usages (references, picker)", has = "references" },
            { "<leader>ci", function() Snacks.picker.lsp_incoming_calls() end, desc = "Incoming Calls (callers of this function)", has = "callHierarchy/incomingCalls" },
            { "<leader>cI", function() Snacks.picker.lsp_outgoing_calls() end, desc = "Outgoing Calls (functions called here)", has = "callHierarchy/outgoingCalls" },
          },
        },
      },
    },
  },

  -- Completion: hiện chữ ký hàm tự động khi gõ "(" ; hiện tên loại (Method/Field...) thay cho icon
  {
    "saghen/blink.cmp",
    opts = {
      -- preset "enter" gán i_<C-k> = bật/tắt chữ ký hàm → chiếm mất digraph gốc của Vim.
      -- Chữ ký đã tự hiện khi gõ "(", và i_<C-s> (gốc Neovim) để gọi thủ công.
      keymap = { ["<C-k>"] = false },
      signature = { enabled = true, window = { border = "rounded" } },
      completion = {
        menu = {
          border = "rounded",
          draw = not vim.g.nerd_font and {
            columns = { { "label", "label_description", gap = 1 }, { "kind" } },
          } or nil,
        },
        documentation = { window = { border = "rounded" } },
      },
    },
  },
}
