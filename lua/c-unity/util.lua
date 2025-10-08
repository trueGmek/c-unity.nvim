local M = {}

local config = require("c-unity.config")

---comment
---@param message string
---@param level integer|nil
M.log = function(message, level)
  if config.debug then
    vim.notify(message, level)
  end
end

return M
