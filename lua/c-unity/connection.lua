local M = {}
local window = require("c-unity.window")
local config = require("c-unity.config")
local log = require("c-unity.utils").log
local payload_gen = require("c-unity.payload_generator")


---The pipe from which the server reads
local ServerReadPipe         = {
  pipe_name = config.connection.server_read_pipe_name,
  pipe_connection = {},
}

---@param self table
---@return boolean: Is the pipe connected
ServerReadPipe.is_connected  = function(self)
  return self.pipe_connection.handle and not self.pipe_connection.handle:is_closing()
end

---@param self any
---@param message string
ServerReadPipe.write         = function(self, message)
  if not self:is_connected() then
    log("Not connected to Unity. Please connect first.", vim.log.WARN)
    return
  end

  vim.loop.write(self.pipe_connection.handle, message .. "\n", function(err)
    if err then
      log("Failed to write to pipe " .. self.pipe_name .. " : " .. err, vim.log.ERROR)
    end
  end)
end

ServerReadPipe.setup         = function(self)
  if self:is_connected() then
    log("Already connected to this pipe: " .. self.pipe_name, vim.log.INFO)
    return
  end

  self.pipe_connection.handle = vim.uv.new_pipe(false)

  vim.uv.pipe_connect(self.pipe_connection.handle, self.pipe_name, function(err)
    if err then
      vim.schedule(function() log("Failed to connect to pipe: " .. self.pipe_name .. ': ' .. err, vim.log.ERROR) end)
      self.pipe_connection = {}
      return
    end
    vim.schedule(function() log("Successfully connected to the pipe: " .. self.pipe_name, vim.log.INFO) end)
  end)
end

ServerReadPipe.disconnect    = function(self)
  if self.pipe_connection.handle and not self.pipe_connection.handle:is_closing() then
    self.pipe_connection.handle:close()
    log("Disconnected from the pipe: " .. self.pipe_name, vim.log.INFO)
  end

  self.pipe_connection = {}
end

---The pipe to which the server writes
local ServerWritePipe        = {
  pipe_name = config.connection.server_write_pipe_name,
  pipe_connection = {},
}

---@param self table
---@return boolean
ServerWritePipe.is_connected = function(self)
  return self.pipe_connection.handle and not self.pipe_connection.handle:is_closing()
end

---Handles incoming data from the Unity server.
---Parses JSON packets and forwards them to the window module.
---@param data string
local handle_data            = function(data)
  local lines = vim.split(data, '\n\n')
  for _, line in ipairs(lines) do
    local isOk, result = pcall(vim.json.decode, line)
    vim.schedule(function()
      if isOk then
        window.append_packet(result)
      else
        log("Could not parse incoming information: " .. data, vim.log.levels.WARN)
      end
    end)
  end
end


---@param self table
---@param on_connection_closed any
ServerWritePipe.setup          = function(self, on_connection_closed)
  on_connection_closed = on_connection_closed or function() end
  if self.pipe_connection.handle and not self.pipe_connection.handle:is_closing() then
    log("Already connected to the pipe: " .. self.pipe_name, vim.log.INFO)
    return
  end

  self.pipe_connection.handle = vim.uv.new_pipe(false)

  vim.uv.pipe_connect(self.pipe_connection.handle, self.pipe_name, function(err)
    if err then
      vim.schedule(
        function()
          log("Failed to connect to Unity pipe: " .. err, vim.log.ERROR)
          self.pipe_connection = {}
        end)
      return
    end

    vim.schedule(function() log("Successfully connected to Unity!", vim.log.INFO) end)

    self.pipe_connection.handle:read_start(function(err, data)
      if err then
        vim.schedule(function()
          log("Error reading from pipe: " .. err, vim.log.ERROR)
        end)
        self.pipe_connection.handle:read_stop();
        self.pipe_connection.handle:close()
        return
      end

      if data == nil then
        on_connection_closed()
        return
      end

      if data then
        handle_data(data)
      end
    end)
  end)
end

ServerWritePipe.disconnect     = function(self)
  if self.pipe_connection.handle and not self.pipe_connection.handle:is_closing() then
    self.pipe_connection.handle:close()
    log("Disconnected from the pipe: " .. self.pipe_name, vim.log.INFO)
  end

  self.pipe_connection = {}
end

---Callback for when the connection to the Unity server is closed.
---Cleans up the pipe connections and calls the user-defined handler.
local handle_closed_connection = function()
  vim.schedule(
    function()
      log("Connection was closed", vim.log.ERROR)
      ServerWritePipe:disconnect()
      ServerReadPipe:disconnect()
      config.connection.handle_broken_connection() end)
end


M.setup_connection = function()
  ServerWritePipe:setup(handle_closed_connection)
  ServerReadPipe:setup()
end

M.disconnect_from_unity = function()
  ServerWritePipe:disconnect()
  ServerReadPipe:disconnect()
end

M.send_recomipile = function()
  local command = "Recompile"
  ServerReadPipe:write(payload_gen.generate_command_json(command))
  window.append_message(payload_gen.generate_command_message(command))
end

M.is_connected = function()
  return ServerWritePipe:is_connected() and ServerReadPipe:is_connected()
end

return M
