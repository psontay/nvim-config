-- Kiểm tra bộ tài liệu NEOVIM_GUIDES còn khớp cấu hình thật.
-- Chạy:  nvim --headless -c "luafile ~/.config/nvim/scripts/check-guides.lua"
-- Tuỳ chọn: KEYHELP_FILES="a.go B.java" để nạp buffer có LSP (phím <leader>c…, Java cxv…).
-- Kiểm tra: (1) tem phiên bản trong MANIFEST.txt, (2) UTF-8 + không rỗng,
-- (3) tham chiếu chéo NN_TEN.txt, (4) mọi <leader>… được nhắc đều có keymap (hoặc là nhóm
-- phím / nằm trong danh sách UNAVAILABLE). Exit code 1 nếu có lỗi.
vim.api.nvim_exec_autocmds("UIEnter", {})

local dir = vim.fn.stdpath("config") .. "/NEOVIM_GUIDES"
-- Phím cố ý được ghi là UNAVAILABLE trong tài liệu
local unavailable = { ["<leader>gg"] = true, ["<leader>cR"] = true }

local function out(s)
  io.stdout:write(s .. "\n")
end

local function read(path)
  local f = io.open(path, "rb")
  if not f then
    return nil
  end
  local s = f:read("*a")
  f:close()
  return s
end

vim.defer_fn(function()
  local errors, warnings = 0, 0

  -- (1) Tem phiên bản
  local manifest = read(dir .. "/MANIFEST.txt") or ""
  local want_nvim = manifest:match("Neovim%s*:%s*(v[%d%.]+)")
  local want_lv = manifest:match("LazyVim%s*:%s*([%d%.]+)")
  local want_lock = manifest:match("sha256 prefix: (%x+)")
  local v = vim.version()
  local have_nvim = string.format("v%d.%d.%d", v.major, v.minor, v.patch)
  local have_lv = LazyVim and LazyVim.config and LazyVim.config.version
  local lock = read(vim.fn.stdpath("config") .. "/lazy-lock.json") or ""
  local have_lock = vim.fn.sha256(lock):sub(1, #(want_lock or ""))
  for _, c in ipairs({
    { "Neovim", want_nvim, have_nvim },
    { "LazyVim", want_lv, have_lv },
    { "lazy-lock", want_lock, have_lock },
  }) do
    if c[2] ~= c[3] then
      out(string.format("STAMP MISMATCH %s: documented %s, current %s", c[1], tostring(c[2]), tostring(c[3])))
      warnings = warnings + 1
    end
  end

  -- buffer có LSP để các phím theo LSP được gắn
  local buf_maps = {}
  for file in (vim.env.KEYHELP_FILES or ""):gmatch("%S+") do
    vim.cmd.edit(vim.fn.fnameescape(file))
    local b = vim.api.nvim_get_current_buf()
    local ready = vim.wait(60000, function()
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = b })) do
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
    vim.wait(4000)
    for _, mode in ipairs({ "n", "x", "o", "i" }) do
      for _, m in ipairs(vim.api.nvim_buf_get_keymap(b, mode)) do
        buf_maps[#buf_maps + 1] = (vim.fn.keytrans(vim.keycode(m.lhs)):gsub("^<Space>", "<leader>"))
      end
    end
  end
  local all = {}
  for _, mode in ipairs({ "n", "x", "o", "i", "t" }) do
    for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
      all[#all + 1] = (vim.fn.keytrans(vim.keycode(m.lhs)):gsub("^<Space>", "<leader>"))
    end
  end
  vim.list_extend(all, buf_maps)
  -- Vim key sequences are case-sensitive. Accept prefixes only for named groups.
  local groups = {
    ["<leader>h"] = true,
    ["<leader>r"] = true,
    ["<leader>d"] = true,
    ["<leader>t"] = true,
    ["<leader>c"] = true,
    ["<leader>f"] = true,
    ["<leader>s"] = true,
    ["<leader>g"] = true,
    ["<leader>x"] = true,
    ["<leader>w"] = true,
    ["<leader>b"] = true,
    ["<leader>q"] = true,
  }
  local function canonical(key)
    key = key:gsub("<leader>", vim.g.mapleader or "\\")
    return vim.fn.keytrans(vim.keycode(key))
  end
  local function is_mapped(tok)
    local lhs = canonical(tok)
    for _, key in ipairs(all) do
      local actual = canonical(key)
      if actual == lhs or groups[tok] and actual:sub(1, #lhs) == lhs then
        return true
      end
    end
    return false
  end

  local files = vim.fn.glob(dir .. "/[0-9][0-9]_*.txt", false, true)
  if #files ~= 16 then
    out("EXPECTED 16 GUIDES, found " .. #files)
    errors = errors + 1
  end
  local names = {}
  for _, f in ipairs(files) do
    names[vim.fn.fnamemodify(f, ":t:r")] = true
  end
  local total_tokens = 0
  for _, f in ipairs(files) do
    local base = vim.fn.fnamemodify(f, ":t")
    local text = read(f)
    -- (2) UTF-8 + không rỗng
    if not text or #vim.trim(text) < 500 then
      out("EMPTY/SHORT " .. base)
      errors = errors + 1
    elseif vim.iconv(vim.iconv(text, "utf-8", "utf-16le") or "", "utf-16le", "utf-8") ~= text then
      out("NOT UTF-8 " .. base)
      errors = errors + 1
    end
    text = text or ""
    -- (3) tham chiếu chéo
    for ref in text:gmatch("(%d%d_[A-Z_]+)%.txt") do
      if not names[ref] then
        out(string.format("BAD REFERENCE %s -> %s.txt", base, ref))
        errors = errors + 1
      end
    end
    -- (4) phím <leader>…
    local seen = {}
    for tok in text:gmatch('<leader>[%w<>%?,%.:|%/%%%-%`"%[%]]+') do
      tok = tok:gsub("`$", "")
      -- Keep real punctuation mappings such as <leader>, and <leader>:.
      while not is_mapped(tok) and not unavailable[tok] and tok:find("[.,:;]$") do
        tok = tok:sub(1, -2)
      end
      if not seen[tok] and tok ~= "<leader>" then
        seen[tok] = true
        total_tokens = total_tokens + 1
        if not unavailable[tok] and not is_mapped(tok) then
          out(string.format("MISSING KEY %s: %s", base, tok))
          errors = errors + 1
        end
      end
    end
  end
  out(
    string.format(
      "check-guides: %d files, %d leader keys checked, %d errors, %d stamp warnings",
      #files,
      total_tokens,
      errors,
      warnings
    )
  )
  vim.cmd(errors > 0 and "cquit 1" or "qall!")
end, 1500)
