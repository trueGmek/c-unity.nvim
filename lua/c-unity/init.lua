local M = {}

local window = require("c-unity.window")
local pipe = require("c-unity.connection")
local generator = require("c-unity.payload_generator")
local config = require("c-unity.config")

local log = require("c-unity.util").log

M.window = window;
M.pipe = pipe
M.generator = generator

---@param opts {timeout: number, repeat_time: number, limit:integer}
local function start_connection_loop(opts)
  log("Starting the connection loop", vim.log.levels.INFO)
  local timer = vim.uv.new_timer()
  local count = 0
  if timer == nil then
    log("Could't get a reference to a timer from vim.uv.new_timer", vim.log.levels.ERROR)
    return
  end

  timer:start(opts.timeout, opts.repeat_time, function()
    if count > opts.limit or pipe.is_connected() then
      timer:close()
    end
    vim.schedule(function()
      log("Trying to connect", vim.log.levels.INFO)
      pipe.setup_connection()
    end)
    count = count + 1
  end)
end


---@param opts {timeout: number, repeat_time: number, limit:integer}?
local function check_if_unity_project(opts)
  opts = opts or config.loop
  local current_dir = vim.fn.getcwd()
  local assets_path = current_dir .. "/Assets"
  local settings_path = current_dir .. "/ProjectSettings"
  if vim.fn.isdirectory(assets_path) == 1 and vim.fn.isdirectory(settings_path) == 1 then
    log("Unity project detected!", vim.log.levels.INFO)
    start_connection_loop(opts)
  end
end

local handle_broken_connection = function()
  vim.schedule(function()
    log("RESTARTING THE LOOP", vim.log.levels.INFO)
    start_connection_loop(config.loop)
  end)
end


---@param opts Config
M.setup = function(opts)
  config.set(opts)
  config.connection.handle_broken_connection = handle_broken_connection

  vim.api.nvim_create_user_command('CULog', window.toggle, { desc = "Toggle logs window" })
  vim.api.nvim_create_user_command('CULogs', window.toggle, { desc = "Toggle logs window" })
  vim.api.nvim_create_user_command('CUClear', window.clear_buffer, { desc = 'Clear logs' })
  vim.api.nvim_create_user_command('CUBuild', pipe.send_recomipile, { desc = "Send recompile command" })
  vim.api.nvim_create_user_command('CUConnect', pipe.setup_connection, { desc = "Connect to Unity Server" })
  vim.api.nvim_create_user_command('CUDisconnect', pipe.disconnect_from_unity, { desc = "Disconnect from Unity Server" })
  vim.api.nvim_create_autocmd("DirChanged", { pattern = "*", callback = check_if_unity_project })

  check_if_unity_project()
end

return M
