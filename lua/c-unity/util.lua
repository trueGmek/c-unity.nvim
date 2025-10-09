local M = {}

local config = require("c-unity.config")

---comment
---@param message string
---@param level integer|nil
M.log = function(message, level)
  if config.debug then
    local data = string.format("[%s] %s", os.date("%H:%M:%S"), message)
    vim.notify(data, level)
  end
end

return M
