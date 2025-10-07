local M = {}

local window = require("c-unity.window")

local _config = {}

M.setup = function(config)
  _config = config

  local pipe = require("c-unity.pipe_connection")
  local generator = require("c-unity.payload_generator")

  vim.api.nvim_create_user_command('UnityLogs', window.toggle, { desc = "Toggle logs window" })
  vim.api.nvim_create_user_command('UnityClear', window.clear_buffer, { desc = 'Clear logs' })
  vim.api.nvim_create_user_command('UnityConnect', pipe.setup_connection, { desc = "Connect to Unity Server" })
  vim.api.nvim_create_user_command('UnityDisconnect', pipe.disconnect_from_unity,
    { desc = "Disconnect from Unity Server" })
  vim.api.nvim_create_user_command('UnityBuild',
    function() pipe.send_message(generator.generate_command_json("Recompile", nil)) end,
    { desc = "Send recompile command" })
end

return M
