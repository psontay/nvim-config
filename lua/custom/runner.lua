-- Chạy / build / test cả project trong terminal phía dưới (Snacks.terminal).
-- Tự nhận diện Go (go.mod), Maven (pom.xml, ưu tiên ./mvnw) và Gradle (./gradlew).
-- Sang terminal: <C-w>j. Trong terminal: `i` để tương tác, <C-c> dừng app,
-- <C-\><C-n> về Normal mode, `q` (Normal mode) ẩn cửa sổ.
local M = {}

M.last = nil ---@type {cmd:string, cwd:string}?

local function file_dir()
  local name = vim.api.nvim_buf_get_name(0)
  return name ~= "" and vim.fs.dirname(name) or vim.uv.cwd()
end

---@return {kind:string, root:string, module:string}?
local function detect()
  local dir = file_dir()
  local go = vim.fs.root(dir, { "go.work", "go.mod" })
  if go then
    return { kind = "go", root = go, module = go }
  end
  local gradle = vim.fs.root(dir, { "gradlew", "settings.gradle", "settings.gradle.kts" })
  if gradle then
    local module = vim.fs.root(dir, { "build.gradle", "build.gradle.kts" }) or gradle
    return { kind = "gradle", root = gradle, module = module }
  end
  -- Maven: module = pom.xml gần file nhất; root = thư mục cao nhất còn pom.xml (project nhiều module)
  local module = vim.fs.root(dir, "pom.xml")
  if module then
    local root = module
    local parent = vim.fs.dirname(root)
    while parent ~= root and vim.uv.fs_stat(parent .. "/pom.xml") do
      root, parent = parent, vim.fs.dirname(parent)
    end
    return { kind = "maven", root = root, module = module }
  end
end

local function rel(path, base)
  return path == base and "." or path:sub(#base + 2)
end

--- Thư mục package main của module Go: <root>/main.go hoặc <root>/cmd/<tên>/main.go đầu tiên
---@param root string
---@return string?
function M.go_main_dir(root)
  if vim.uv.fs_stat(root .. "/main.go") then
    return root
  end
  local mains = vim.fn.glob(root .. "/cmd/*/main.go", false, true)
  return mains[1] and vim.fs.dirname(mains[1]) or nil
end

---@param p {kind:string, root:string, module:string}
---@param action "run"|"build"|"test"
---@return string? cmd, string? cwd
local function command(p, action)
  if p.kind == "go" then
    if action == "run" then
      local main = M.go_main_dir(p.root)
      if main then
        return main == p.root and "go run ." or ("go run ./" .. rel(main, p.root)), p.root
      end
      return "go run .", file_dir()
    end
    return ({ build = "go build ./...", test = "go test ./..." })[action], p.root
  elseif p.kind == "maven" then
    local mvn = vim.uv.fs_stat(p.root .. "/mvnw") and "./mvnw" or "mvn"
    local target = p.module ~= p.root and (" -pl " .. rel(p.module, p.root) .. " -am") or ""
    if action == "run" then
      -- spring-boot:run chỉ chạy được trong module ứng dụng; -am build kèm module phụ thuộc
      local run = p.module ~= p.root and (" -pl " .. rel(p.module, p.root)) or ""
      return mvn .. run .. " spring-boot:run", p.root
    end
    return mvn .. target .. ({ build = " package -DskipTests", test = " test" })[action], p.root
  elseif p.kind == "gradle" then
    local gradle = vim.uv.fs_stat(p.root .. "/gradlew") and "./gradlew" or "gradle"
    local prefix = p.module ~= p.root and (":" .. rel(p.module, p.root):gsub("/", ":") .. ":") or ""
    return gradle .. " " .. prefix .. ({ run = "bootRun", build = "build -x test", test = "test" })[action], p.root
  end
end

local function open(cmd, cwd)
  M.last = { cmd = cmd, cwd = cwd }
  Snacks.terminal.open(cmd, {
    cwd = cwd,
    auto_close = false,
    start_insert = false,
    auto_insert = false,
    -- Con trỏ ở lại cửa sổ code; sang terminal bằng <C-w>j (lệnh cửa sổ gốc của Vim)
    win = { position = "bottom", height = 0.35, title = cmd, enter = false },
  })
end

---@param action "run"|"build"|"test"|"custom"|"last"
function M.run(action)
  if action == "last" then
    if not M.last then
      return vim.notify("No previous runner command.", vim.log.levels.WARN)
    end
    return open(M.last.cmd, M.last.cwd)
  end
  local p = detect()
  if action == "custom" then
    local cwd = p and p.root or vim.uv.cwd()
    vim.ui.input(
      { prompt = "Command (" .. vim.fn.fnamemodify(cwd, ":~") .. "): ", default = M.last and M.last.cmd or "" },
      function(input)
        if input and input ~= "" then
          open(input, cwd)
        end
      end
    )
    return
  end
  if not p then
    return vim.notify("No Go, Maven, or Gradle project found from this file.", vim.log.levels.WARN)
  end
  local cmd, cwd = command(p, action)
  open(cmd, cwd)
end

M._detect, M._command = detect, command -- dùng cho kiểm thử
return M
