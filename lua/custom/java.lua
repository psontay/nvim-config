-- Phát hiện các JDK đã cài (sdkman, /usr/lib/jvm, ~/.jdks) để:
--  1. chạy jdtls bằng JDK >= 21 (yêu cầu của eclipse.jdt.ls), bất kể JAVA_HOME đang trỏ đâu;
--  2. khai báo java.configuration.runtimes → mỗi project được biên dịch/kiểm tra với đúng JDK
--     mà pom.xml/build.gradle yêu cầu (vd project Java 8 không bị phân tích bằng JDK 21).
local M = {}

local function major_of(home)
  local f = io.open(home .. "/release", "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  local v = content:match('JAVA_VERSION="([^"]+)"')
  if not v then
    return nil
  end
  local first, second = v:match("^(%d+)%.?(%d*)")
  first = tonumber(first)
  if first == 1 then
    return tonumber(second) -- 1.8.0_xxx → 8
  end
  return first
end

---@return {major:integer, path:string}[] sắp xếp theo major tăng dần, mỗi major một JDK
function M.jdks()
  if M._cache then
    return M._cache
  end
  local candidates = {}
  for _, pattern in ipairs({
    vim.env.JAVA_HOME or "",
    "~/.sdkman/candidates/java/*",
    "/usr/lib/jvm/*",
    "~/.jdks/*",
  }) do
    if pattern ~= "" then
      vim.list_extend(candidates, vim.fn.glob(pattern, false, true))
    end
  end
  local by_major, seen = {}, {}
  for _, dir in ipairs(candidates) do
    local real = vim.uv.fs_realpath(dir)
    if real and not seen[real] and vim.fn.executable(real .. "/bin/java") == 1 then
      seen[real] = true
      local major = major_of(real)
      if major and not by_major[major] then
        by_major[major] = real
      end
    end
  end
  local list = {}
  for major, path in pairs(by_major) do
    list[#list + 1] = { major = major, path = path }
  end
  table.sort(list, function(a, b)
    return a.major < b.major
  end)
  M._cache = list
  return list
end

--- JDK dùng để chạy jdtls: ưu tiên JAVA_HOME nếu >= 21, nếu không lấy JDK >= 21 mới nhất.
function M.launcher_home()
  local home = vim.env.JAVA_HOME and vim.uv.fs_realpath(vim.env.JAVA_HOME)
  if home and (major_of(home) or 0) >= 21 then
    return home
  end
  local best
  for _, jdk in ipairs(M.jdks()) do
    if jdk.major >= 21 then
      best = jdk.path
    end
  end
  return best
end

--- Giá trị cho settings.java.configuration.runtimes
function M.runtimes()
  local default = vim.env.JAVA_HOME and vim.uv.fs_realpath(vim.env.JAVA_HOME)
  local ret = {}
  for _, jdk in ipairs(M.jdks()) do
    ret[#ret + 1] = {
      name = jdk.major == 8 and "JavaSE-1.8" or ("JavaSE-" .. jdk.major),
      path = jdk.path,
      default = jdk.path == default or nil,
    }
  end
  return ret
end

local BUILD_FILES = { "pom.xml", "build.gradle", "build.gradle.kts" }

local function has_build_file(dir)
  for _, f in ipairs(BUILD_FILES) do
    if vim.uv.fs_stat(dir .. "/" .. f) then
      return true
    end
  end
  return false
end

--- Root project cho jdtls: một server cho cả project nhiều module.
--- Gradle: thư mục có settings.gradle. Maven: đi ngược lên chừng nào thư mục cha còn pom.xml/build.gradle
--- (không phụ thuộc .git, nên monorepo chứa nhiều project độc lập vẫn tách đúng).
function M.root_dir(path)
  local settings = vim.fs.root(path, { "settings.gradle", "settings.gradle.kts" })
  if settings then
    return settings
  end
  local dir = vim.fs.root(path, BUILD_FILES)
  if not dir then
    return vim.fs.root(path, { ".git", "mvnw", "gradlew" })
  end
  local parent = vim.fs.dirname(dir)
  while parent ~= dir and has_build_file(parent) do
    dir, parent = parent, vim.fs.dirname(parent)
  end
  return dir
end

--- Tên workspace jdtls duy nhất cho mỗi đường dẫn project
--- (2 project cùng tên thư mục, vd ~/a/backend và ~/b/backend, không dùng chung dữ liệu).
function M.project_name(root_dir)
  if not root_dir then
    return nil
  end
  return vim.fs.basename(root_dir) .. "-" .. vim.fn.sha256(root_dir):sub(1, 8)
end

return M
