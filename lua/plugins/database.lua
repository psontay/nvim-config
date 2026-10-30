return {
  {
    "tpope/vim-dadbod",
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    -- Chỉ tải plugin này khi bạn gọi lệnh (giúp Neovim khởi động nhanh)
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    init = function()
      -- Cấu hình giao diện chuẩn JetBrains
      vim.g.db_ui_use_nerd_fonts = vim.g.nerd_font and 1 or 0
      vim.g.db_ui_win_position = "right" -- Đặt thanh UI ở bên phải
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_execute_on_save = 0 -- Tắt tự động chạy query khi save (để an toàn)
    end,
    -- Cài đặt phím tắt siêu tốc
    keys = {
      { "<leader>D", "<cmd>DBUIToggle<cr>", desc = "Toggle Database UI" },
    },
  },

  -- Gợi ý bảng/cột trong buffer SQL của DBUI (nguồn completion "dadbod" cho blink.cmp)
  {
    "kristijanhusak/vim-dadbod-completion",
    lazy = true,
  },
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        per_filetype = {
          sql = { "snippets", "dadbod", "buffer" },
          mysql = { "snippets", "dadbod", "buffer" },
          plsql = { "snippets", "dadbod", "buffer" },
        },
        providers = {
          dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
        },
      },
    },
  },

  { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = { "sql" } } },
}
