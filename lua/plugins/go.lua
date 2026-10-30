-- Go / Gin — bổ sung cho extra lazyvim.plugins.extras.lang.go (gopls, delve, neotest-golang)
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              -- Format chuẩn gofmt/goimports như GoLand (gofumpt khắt khe hơn → diff thừa trong project chung)
              gofumpt = false,
              -- ST1000 ("package comment") cảnh báo ở dòng 1 mọi package → nhiễu, tắt riêng
              analyses = { ST1000 = false },
            },
          },
        },
      },
    },
  },

  -- Formatter: chỉ goimports (= gofmt + sắp xếp/thêm/xoá import)
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.go = { "goimports" }
    end,
  },

  -- golangci-lint chỉ chạy khi project có file cấu hình riêng; nếu không, gopls (vet + staticcheck)
  -- đã báo đủ lỗi và tránh trùng lặp diagnostics.
  -- Không khai báo qua linters_by_ft/opts.linters: module golangcilint của nvim-lint chạy
  -- `golangci-lint version` ngay khi được nạp (~50ms mỗi lần mở bất kỳ file nào).
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft.go = nil
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("custom_golangci_lint", { clear = true }),
        pattern = "*.go",
        callback = function(ev)
          local config = vim.fs.find(
            { ".golangci.yml", ".golangci.yaml", ".golangci.toml", ".golangci.json" },
            { path = vim.fs.dirname(ev.file), upward = true }
          )[1]
          if config and vim.fn.executable("golangci-lint") == 1 then
            -- chạy tại root module (không phụ thuộc thư mục đang mở Neovim)
            require("lint").try_lint("golangcilint", { cwd = vim.fs.root(ev.file, "go.mod") })
          end
        end,
      })
    end,
  },
}
