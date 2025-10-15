local M = {}

local window = require("c-unity.window")
local pipe = require("c-unity.connection")
local generator = require("c-unity.payload_generator")
local config = require("c-unity.config")
local editor = require("c-unity.editor_handler")

local utils = require("c-unity.utils")
local log = utils.log


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


---Checks if the current directory is a Unity project and starts the connection loop.
---@param opts {timeout: number, repeat_time: number, limit:integer}?
local function try_unity_project_startup(opts)
  opts = opts or config.loop
  if utils.is_unity_project() then
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

M.window = window;
M.pipe = pipe
M.generator = generator
M.editor = editor

---@param opts Config?
M.setup = function(opts)
  config.set(opts)
  config.connection.handle_broken_connection = handle_broken_connection
  vim.api.nvim_create_autocmd("DirChanged", { pattern = "*", callback = try_unity_project_startup })
  try_unity_project_startup()
end

return M
