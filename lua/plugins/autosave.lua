return {
  {
    "okuuva/auto-save.nvim",
    cmd = "ASToggle",
    event = { "InsertLeave", "TextChanged" },
    keys = {
      { "<leader>uv", "<cmd>ASToggle<cr>", desc = "Toggle Auto-save" },
    },
    opts = {
      enabled = true,
      -- Định dạng mới của auto-save.nvim (dạng danh sách cũ bị plugin bỏ qua)
      trigger_events = {
        immediate_save = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" },
        defer_save = { "InsertLeave", "TextChanged" },
        cancel_deferred_save = { "InsertEnter" },
      },
      debounce_delay = 1000,
      -- Chỉ lưu file thật: bỏ qua buffer đặc biệt (terminal, dbui, picker, help...)
      condition = function(buf)
        return vim.bo[buf].modifiable and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= ""
      end,
      -- Format khi auto-save bị tắt trong autocmds.lua (chỉ format khi :w thủ công)
    },
  },
}
