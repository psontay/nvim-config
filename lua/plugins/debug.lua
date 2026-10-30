-- Debug (nvim-dap) & test (neotest) — bổ sung cho extras dap.core / test.core
return {
  {
    "mfussenegger/nvim-dap",
    optional = true, -- chỉ áp dụng khi extra dap.core đang bật
    -- Phím F giống IntelliJ/GoLand (KDE chiếm Ctrl+F7/F9/F10 nên không dùng tổ hợp Ctrl)
    -- stylua: ignore
    keys = {
      { "<F9>", function() require("dap").continue() end, desc = "Debug: Run/Continue" },
      { "<F8>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
      { "<F7>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
      { "<S-F8>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
      -- Konsole gửi Shift+F8 dưới dạng <F20> ở một số chế độ bàn phím
      { "<F20>", function() require("dap").step_out() end, desc = "which_key_ignore" },
    },
  },

  -- "Debug Package" của dap-go chạy theo thư mục FILE đang mở (đứng ở handler/ sẽ lỗi vì không có main).
  -- Thêm cấu hình chạy package main của module dù đang mở file nào (giống <leader>rr).
  {
    "leoluz/nvim-dap-go",
    optional = true,
    opts = {
      dap_configurations = {
        {
          type = "go",
          name = "Debug app (module main package)",
          request = "launch",
          program = function()
            local root = vim.fs.root(0, { "go.work", "go.mod" }) or vim.uv.cwd()
            return require("custom.runner").go_main_dir(root) or root
          end,
          cwd = function()
            return vim.fs.root(0, { "go.work", "go.mod" }) or vim.uv.cwd()
          end,
        },
      },
    },
    config = function(_, opts)
      require("dap-go").setup(opts)
      -- delve build chương trình theo thư mục của TIẾN TRÌNH delve (mặc định = cwd của Neovim).
      -- Mở Neovim ngoài project → "go.mod file not found". Luôn khởi động delve tại root module.
      local dap = require("dap")
      local adapter = dap.adapters.go
      dap.adapters.go = function(callback, config)
        adapter(function(resolved)
          resolved = vim.deepcopy(resolved)
          resolved.executable.cwd = config.cwd or vim.fs.root(0, { "go.work", "go.mod" }) or resolved.executable.cwd
          callback(resolved)
        end, config)
      end
    end,
  },

  -- Go được nvim-dap-go cấu hình, Java được nvim-jdtls cấu hình → không để mason-nvim-dap
  -- thêm bộ cấu hình thứ hai ("Delve: Debug"...) gây trùng lặp trong danh sách chọn.
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = {
      handlers = {
        delve = function() end,
        javadbg = function() end,
        javatest = function() end,
      },
    },
  },
}
