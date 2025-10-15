local M = {}

local config = require("c-unity.config")

---@param message string
---@param level integer|nil
M.log = function(message, level)
  if level == vim.log.levels.ERROR then
    local data = string.format("[%s] %s", os.date("%H:%M:%S"), message)
    vim.notify(data, level)
  elseif config.debug then
    local data = string.format("[%s] %s", os.date("%H:%M:%S"), message)
    vim.notify(data, level)
  end
end

---Checks whether current working directory is a Unity project
---@return boolean: true if CWD is a Unity project
M.is_unity_project = function()
  local current_dir = vim.fn.getcwd()
  local assets_path = current_dir .. "/Assets"
  local settings_path = current_dir .. "/ProjectSettings"
  return vim.fn.isdirectory(assets_path) == 1 and vim.fn.isdirectory(settings_path) == 1
end

---Asynchronous read function taken from luv-file-system-operations
---@param path string
---@param callback function
M.read_file = function(path, callback)
  ---vim.uv.fs_open doesn't expand paths automatically. A path that starts with: '~' will be treated as a relative path
  path = vim.fn.expand(path)
  vim.uv.fs_open(path, "r", 438, function(err, fd)
    assert(not err, err)
    vim.uv.fs_fstat(fd, function(err, stat)
      assert(not err, err)
      vim.uv.fs_read(fd, stat.size, 0, function(err, data)
        assert(not err, err)
        vim.uv.fs_close(fd, function(err)
          assert(not err, err)
          return callback(data)
        end)
      end)
    end)
  end)
end

---Synchronous read function taken from luv-file-system-operations
---@param path string
---@return string
M.read_file_sync = function(path)
  ---vim.uv.fs_open doesn't expand paths automatically. A path that starts with: '~' will be treated as a relative path
  path = vim.fn.expand(path)
  local fd = assert(vim.uv.fs_open(path, "r", 438))
  local stat = assert(vim.uv.fs_fstat(fd))
  local data = assert(vim.uv.fs_read(fd, stat.size, 0))
  assert(vim.uv.fs_close(fd))
  return data
end

return M
