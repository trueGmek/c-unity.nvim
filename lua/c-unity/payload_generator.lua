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
function M.generate_command_json(action, arguments)
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

-- Example 1:
-- local recompile_json = M.generate_command_json("Recompile", nil)
-- print("\nJSON to send:", recompile_json)
-- {
--   "type": "command",
--   "id": "test",
--   "payload": {
--     "action": "Recompile",
--     "arguments": null
--   }
-- }
--
-- {
--   "payload": {
--     "arguments": [],
--     "action": "Recompile"
--   },
--   "id": "nvim_cmd_2025-10-02-13:38:49_306",
--   "type": "command"
-- }
return M
