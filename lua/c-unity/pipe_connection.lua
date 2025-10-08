local M           = {}

local window      = require("c-unity.window")
local payload_gen = require("c-unity.payload_generator")

local _config     = { debug = false }

M.setup           = function(config)
  _config = config or {}
end


local ServerInPipe             = {
  pipe_name = "/tmp/unity-pipe-read",
  pipe_connection = {},
  ---comment
  ---@param self any
  ---@param message string
  write = function(self, message)
    if not self.pipe_connection.handle or self.pipe_connection.handle:is_closing() then
      vim.notify("Not connected to Unity. Please connect first.", vim.log.WARN)
      return
    end

    -- Write the message to the pipe.
    vim.loop.write(self.pipe_connection.handle, message .. "\n", function(err)
      if err then
        vim.notify("Failed to write to pipe " .. self.pipe_name .. " : " .. err, vim.log.ERROR)
      end
    end)
  end,

  setup = function(self)
    if self.pipe_connection.handle and not self.pipe_connection.handle:is_closing() then
      vim.notify("Already connected to this pipe: " .. self.pipe_name, vim.log.INFO)
      return
    end

    self.pipe_connection.handle = vim.uv.new_pipe(false)

    vim.uv.pipe_connect(self.pipe_connection.handle, self.pipe_name, function(err)
      if err then
        vim.schedule(function() vim.notify("Failed to connect to pipe: " .. self.pipe_name .. ': ' .. err, vim.log.ERROR) end)
        return
      end

      vim.schedule(function() vim.notify("Successfully connected to the pipe: " .. self.pipe_name, vim.log.INFO) end)
    end)
  end,

  disconnect = function(self)
    if self.pipe_connection.handle and not self.pipe_connection.handle:is_closing() then
      self.pipe_connection.handle:close()
      vim.notify("Disconnected from the pipe: " .. self.pipe_name, vim.log.INFO)
    end

    self.pipe_connection = {}
  end
}

local ServerOutPipe            = {
  pipe_name = "/tmp/unity-pipe-write",
  pipe_connection = {},
  setup = function(self, on_connection_closed)
    on_connection_closed = on_connection_closed or function() end
    if self.pipe_connection.handle and not self.pipe_connection.handle:is_closing() then
      vim.notify("Already connected to the pipe: " .. self.pipe_name, vim.log.INFO)
      return
    end

    self.pipe_connection.handle = vim.uv.new_pipe(false)

    vim.uv.pipe_connect(self.pipe_connection.handle, self.pipe_name, function(err)
      if err then
        vim.schedule(
          function()
            vim.notify("Failed to connect to Unity pipe: " .. err, vim.log.ERROR)
          end)
        return
      end

      vim.schedule(function()
        vim.notify("Successfully connected to Unity!", vim.log.INFO)
      end)


      self.pipe_connection.handle:read_start(function(err, data)
        if err then
          vim.schedule(function() vim.notify("Error reading from pipe: " .. err, vim.log.ERROR) end)
          self.pipe_connection.handle:read_stop();
          self.pipe_connection.handle:close()
          return
        end

        if data == nil then
          on_connection_closed()
          return
        end

        if data then
          vim.schedule(function()
            local lines = vim.split(data, '\n\n')
            for _, line in ipairs(lines) do
              local isOk, result = pcall(vim.json.decode, line)
              if isOk then
                window.append_log(result)
              elseif _config.debug then
                vim.notify("Could not parse incoming information: " .. data, vim.log.levels.ERROR)
              end
            end
          end)
        end
      end)
    end)
  end,

  disconnect = function(self)
    if self.pipe_connection.handle and not self.pipe_connection.handle:is_closing() then
      self.pipe_connection.handle:close()
      vim.notify("Disconnected from the pipe: " .. self.pipe_name, vim.log.INFO)
    end

    self.pipe_connection = {}
  end
}

local handle_closed_connection = function()
  vim.schedule(
    function()
      vim.notify("Connection was closed", vim.log.ERROR)
      ServerOutPipe:disconnect()
      ServerInPipe:disconnect()
    end)
end

-- A function to connect to the Unity named pipe.
M.setup_connection             = function()
  ServerOutPipe:setup(handle_closed_connection)
  ServerInPipe:setup()
end

M.disconnect_from_unity        = function()
  ServerOutPipe:disconnect()
  ServerInPipe:disconnect()
end

M.send_recomipile              = function()
  local command = "Recompile"
  ServerInPipe:write(payload_gen.generate_command_json(command))
  window.append_message(payload_gen.generate_command_message(command))
end


return M
