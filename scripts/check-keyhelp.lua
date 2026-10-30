-- Kiểm tra dữ liệu :KeyHelp khớp với cấu hình thực tế.
-- Chạy:  nvim --headless -c "luafile ~/.config/nvim/scripts/check-keyhelp.lua"
-- Tuỳ chọn: KEYHELP_FILES="path/a.go path/B.java" để kiểm tra cả keymap gắn theo LSP (gd, <leader>cr, Java...).
-- Kết quả in ra stdout; exit code 1 nếu có lỗi.
vim.api.nvim_exec_autocmds("UIEnter", {})

local function out(s)
  io.stdout:write(s .. "\n")
end

vim.defer_fn(function()
  local errors, checked = 0, 0
  local buf_maps = {} ---@type table<string, boolean>
  local function collect(buf)
    for _, mode in ipairs({ "n", "x", "o", "i", "t" }) do
      for _, m in ipairs(vim.api.nvim_buf_get_keymap(buf, mode)) do
        buf_maps[mode .. vim.fn.keytrans(vim.keycode(m.lhs))] = true
      end
    end
  end
  for file in (vim.env.KEYHELP_FILES or ""):gmatch("%S+") do
    vim.cmd.edit(vim.fn.fnameescape(file))
    local buf = vim.api.nvim_get_current_buf()
    local ready = vim.wait(60000, function()
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
        if client.initialized then
          return true
        end
      end
      return false
    end, 200)
    if not ready then
      out("LSP NOT READY " .. file)
      errors = errors + 1
    end
    vim.wait(4000) -- keymap theo capability + keymap riêng của jdtls được gắn sau LspAttach
    collect(buf)
  end

  local function mapped(key, modes)
    local lhs = key:gsub("^[ict]_", "")
    -- Text object của mini.ai: plugin map chung `a`/`i` (x,o) rồi đọc ký tự kế tiếp
    if modes == "x,o" and #lhs == 2 and lhs:find("^[ai]") then
      local m = vim.fn.maparg(lhs:sub(1, 1), "o", false, true)
      if m and (m.desc or ""):find("[Aa]round") or (m.desc or ""):find("[Ii]nside") then
        return true
      end
    end
    for mode in modes:gmatch("[^,]+") do
      if mode ~= "c" then
        local m = vim.fn.maparg(lhs, mode, false, true)
        if not ((m and m.lhs) or buf_maps[mode .. vim.fn.keytrans(vim.keycode(lhs))]) then
          return false
        end
      end
    end
    return true
  end

  local seen = {}
  local kh = require("custom.keyhelp")
  for _, item in ipairs(kh.items()) do
    local id = item.key .. "|" .. item.modes
    if seen[id] then
      out("DUPLICATE  " .. item.key)
      errors = errors + 1
    end
    seen[id] = true
    if item.src ~= "native" and not item.key:find("^[ict]_") and not item.key:find("^[:{]") then
      checked = checked + 1
      if not mapped(item.key, item.modes) then
        out("NOT MAPPED " .. item.key .. " (" .. item.modes .. ")")
        errors = errors + 1
      end
    end
    local tag = item.help
    if not tag and item.src == "native" then
      tag = kh._help_tag(item)
    end
    if tag and item.src == "native" and #vim.fn.getcompletion(tag, "help") == 0 then
      out("NO :help    " .. item.key .. " -> " .. tag)
      errors = errors + 1
    end
  end
  out(string.format("KeyHelp: %d entries, %d custom/plugin mappings checked, %d errors", #kh.items(), checked, errors))
  vim.cmd(errors > 0 and "cquit 1" or "qall!")
end, 1500)
