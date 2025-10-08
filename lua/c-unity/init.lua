local M = {}

local window = require("c-unity.window")
local pipe = require("c-unity.pipe_connection")
local generator = require("c-unity.payload_generator")

M.window = window;
M.pipe = pipe
M.generator = generator

local _config = { debug = false }

M.setup = function(config)
  _config = config

  vim.api.nvim_create_user_command('CULog', window.toggle, { desc = "Toggle logs window" })
  vim.api.nvim_create_user_command('CULogs', window.toggle, { desc = "Toggle logs window" })
  vim.api.nvim_create_user_command('CUClear', window.clear_buffer, { desc = 'Clear logs' })
  vim.api.nvim_create_user_command('CUBuild', pipe.send_recomipile, { desc = "Send recompile command" })
  vim.api.nvim_create_user_command('CUConnect', pipe.setup_connection, { desc = "Connect to Unity Server" })
  vim.api.nvim_create_user_command('CUDisconnect', pipe.disconnect_from_unity,
    { desc = "Disconnect from Unity Server" })
end

return M
