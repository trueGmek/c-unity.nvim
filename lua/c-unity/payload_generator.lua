local M = {}

--- @return string A unique ID string.
local function generate_command_id()
  local timestamp = os.date("%Y-%m-%d-%H:%M:%S")
  local rand = math.random(1, 1000)
  return string.format("nvim_cmd_%s_%d", timestamp, rand)
end

--- @param action string The specific command action (e.g., "Recompile", "RunTest").
--- @param arguments table? Optional table of key-value pairs for command arguments.
--- @return string The serialized JSON string with a newline delimiter.
M.generate_command_json = function(action, arguments)
  local command_data = {
    id = generate_command_id(),
    type = "command",
    payload = {
      action = action,
      arguments = arguments or nil
    }
  }

  return vim.json.encode(command_data) .. '\n'
end


--- @param action string The specific command action (e.g., "Recompile", "RunTest").
--- @param arguments table? Optional table of key-value pairs for command arguments.
--- @return string Log message
M.generate_command_message = function(action, arguments)
  local separator = "----"
  local message = string.format("[%s][Nvim] Sending a %s command with arguments: %s",
    os.date("%H:%M:%S"),
    string.lower(action),
    tostring(arguments))

  return separator .. '\n' .. message .. '\n' .. separator .. '\n'
end

return M
