-- Giao diện tối giản: không tabline, không dashboard, không hiệu ứng, cmdline gốc của Vim.
local nerd = vim.g.nerd_font
local icons = require("custom.icons")

return {
  -- Bộ icon dùng chung của LazyVim (diagnostics, git, dap, kinds) → ký hiệu thường
  {
    "LazyVim/LazyVim",
    opts = not nerd and {
      icons = {
        misc = { dots = "…" },
        diagnostics = icons.diagnostics,
        git = icons.git,
        dap = icons.dap,
        kinds = icons.kinds,
      },
    } or {},
  },

  -- Thanh buffer phía trên: trùng thông tin với picker buffer (<leader>,) → tắt
  { "akinsho/bufferline.nvim", enabled = false },
  -- noice thay cmdline/messages bằng popup; giữ cmdline gốc để học Command-line mode
  { "folke/noice.nvim", enabled = false },
  -- Không cần theme dự phòng (đang dùng habamax có sẵn)
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", name = "catppuccin", enabled = false },

  {
    "nvim-mini/mini.icons",
    opts = { style = nerd and "glyph" or "ascii" },
  },

  {
    "folke/snacks.nvim",
    opts = {
      dashboard = { enabled = false },
      scroll = { enabled = false },
      indent = { animate = { enabled = false }, scope = { enabled = true } },
      notifier = { timeout = 3000, style = "compact" },
      picker = not nerd and {
        icons = {
          files = { enabled = false },
          keymaps = { nowait = "! " },
          undo = { saved = "S " },
          ui = { live = "~ " },
          git = {
            commit = "* ",
            added = "+",
            deleted = "-",
            ignored = "!",
            renamed = "→",
            unmerged = "U",
          },
          diagnostics = icons.diagnostics,
          lsp = { unavailable = "-", enabled = "+ ", disabled = "- ", attached = "● " },
          kinds = icons.kinds,
        },
      } or {},
    },
  },

  {
    "folke/which-key.nvim",
    opts = {
      icons = { mappings = nerd },
      spec = {
        { "<leader>h", group = "help/learn Vim" },
        { "<leader>r", group = "run/build" },
      },
    },
  },

  { "folke/todo-comments.nvim", opts = { signs = false } },

  -- ── Không Nerd Font: thay các glyph mặc định (vùng Private Use, Konsole hiện thành ô vuông) ──
  -- Dấu "dòng bị xoá" của gitsigns
  {
    "lewis6991/gitsigns.nvim",
    opts = not nerd and {
      signs = { delete = { text = "▁" }, topdelete = { text = "▔" } },
      signs_staged = { delete = { text = "▁" }, topdelete = { text = "▔" } },
    } or {},
  },
  -- Tên phím trong popup which-key (<C-…>, <CR>…) thay vì glyph
  {
    "folke/which-key.nvim",
    opts = not nerd and {
      icons = {
        keys = {
          Up = "<Up> ",
          Down = "<Down> ",
          Left = "<Left> ",
          Right = "<Right> ",
          C = "<C-…> ",
          M = "<M-…> ",
          D = "<D-…> ",
          S = "<S-…> ",
          CR = "<CR> ",
          Esc = "<Esc> ",
          NL = "<NL> ",
          BS = "<BS> ",
          Space = "<Space> ",
          Tab = "<Tab> ",
          ScrollWheelDown = "<ScrollWheelDown> ",
          ScrollWheelUp = "<ScrollWheelUp> ",
          F1 = "<F1>",
          F2 = "<F2>",
          F3 = "<F3>",
          F4 = "<F4>",
          F5 = "<F5>",
          F6 = "<F6>",
          F7 = "<F7>",
          F8 = "<F8>",
          F9 = "<F9>",
          F10 = "<F10>",
          F11 = "<F11>",
          F12 = "<F12>",
        },
      },
    } or {},
  },
  -- Thông báo (snacks.notifier)
  {
    "folke/snacks.nvim",
    opts = not nerd and {
      notifier = { icons = { error = "E ", warn = "W ", info = "I ", debug = "D ", trace = "T " } },
    } or {},
  },
  -- Debug UI
  {
    "rcarriga/nvim-dap-ui",
    optional = true,
    opts = not nerd and {
      icons = { expanded = "▾", collapsed = "▸", current_frame = "→" },
      controls = {
        icons = {
          pause = "⏸",
          play = "▶",
          step_into = "↓",
          step_over = "→",
          step_out = "↑",
          step_back = "←",
          run_last = "↻",
          terminate = "■",
          disconnect = "⏏",
        },
      },
    } or {},
  },
  -- Kết quả test (neotest)
  {
    "nvim-neotest/neotest",
    optional = true,
    opts = not nerd and {
      icons = {
        passed = "✓",
        running = "…",
        failed = "✗",
        skipped = "↷",
        unknown = "?",
        watching = "◉",
        test = "▸",
        notify = "!",
        dir = "▸",
        file = "▪",
        namespace = "▪",
      },
    } or {},
  },
  {
    "folke/trouble.nvim",
    opts = not nerd and {
      icons = {
        indent = { fold_open = "▾ ", fold_closed = "▸ " },
        folder_closed = "▸ ",
        folder_open = "▾ ",
        kinds = icons.kinds,
      },
    } or {},
  },
  { "MagicDuck/grug-far.nvim", opts = not nerd and { icons = { enabled = false } } or {} },
  {
    "folke/todo-comments.nvim",
    opts = not nerd and {
      keywords = {
        FIX = { icon = "F " },
        TODO = { icon = "T " },
        HACK = { icon = "H " },
        WARN = { icon = "W " },
        PERF = { icon = "P " },
        NOTE = { icon = "N " },
        TEST = { icon = "✓ " },
      },
    } or {},
  },

  -- Statusline gọn: mode | branch | file | diagnostics ... tiến trình LSP | debug | diff | vị trí
  {
    "nvim-lualine/lualine.nvim",
    init = function()
      vim.g.trouble_lualine = false
    end,
    opts = function()
      local lualine_require = require("lualine_require")
      lualine_require.require = require
      vim.o.laststatus = vim.g.lualine_laststatus
      local ic = LazyVim.config.icons

      return {
        options = {
          theme = "auto",
          globalstatus = vim.o.laststatus == 3,
          icons_enabled = nerd,
          section_separators = "",
          component_separators = "",
          disabled_filetypes = { statusline = { "snacks_dashboard" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { { "branch", icon = nerd and "" or "" } },
          lualine_c = {
            {
              LazyVim.lualine.pretty_path({
                modified_sign = " [+]",
                readonly_icon = " [RO]",
              }),
            },
            {
              "diagnostics",
              symbols = {
                error = ic.diagnostics.Error,
                warn = ic.diagnostics.Warn,
                info = ic.diagnostics.Info,
                hint = ic.diagnostics.Hint,
              },
            },
          },
          lualine_x = {
            Snacks.profiler.status(),
            -- Tiến trình LSP (vd jdtls đang import Maven project)
            {
              function()
                local s = vim.lsp.status()
                return #s > 50 and (s:sub(1, 49) .. "…") or s
              end,
              color = function()
                return { fg = Snacks.util.color("Comment") }
              end,
            },
            {
              function()
                return "DEBUG " .. require("dap").status()
              end,
              cond = function()
                return package.loaded["dap"] and require("dap").status() ~= ""
              end,
              color = function()
                return { fg = Snacks.util.color("Debug") }
              end,
            },
            {
              "diff",
              symbols = { added = ic.git.added, modified = ic.git.modified, removed = ic.git.removed },
              source = function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return { added = gitsigns.added, modified = gitsigns.changed, removed = gitsigns.removed }
                end
              end,
            },
            { "filetype", colored = false },
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        extensions = { "lazy" },
      }
    end,
  },
}
