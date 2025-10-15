local config = require("c-unity.config")
local utils = require("c-unity.utils")

local M = {}

---Extracts editor version from /ProjectSettings/ProjectVersion.txt
---@return string?
local extract_editor_version = function()
  local path = "./ProjectSettings/ProjectVersion.txt"
  local lines = vim.fn.split(utils.read_file_sync(path), '\n')

  for _, line in ipairs(lines) do
    local k, v = line:match("^%s*(%S+):%s*(.-)%s*$")
    if k == 'm_EditorVersion' then
      return v
    end
  end

  return nil
end

---Tries to open Unity Editor with project at current working directory
M.open_project = function()
  utils.log("TRYING TO OPEN THE PROJECT", vim.INFO)

  if utils.is_unity_project() == false then
    utils.log("Current working directory is not a Unity project", vim.log.levels.ERROR)
    return
  end

  if config.unity.path:len() == 0 then
    utils.log("Unity path was not set!", vim.log.levels.ERROR)
    return
  end

  local version = extract_editor_version()
  assert(version, "Could not extract Unity version!")

  local path = vim.fs.joinpath(vim.fn.expand(config.unity.path), version, "Editor", "Unity")

  -- /home/<user>/Unity/Hub/Editor/<version>/Editor/Unity -projectPath <project path>
  local command = path .. " -projectPath " .. vim.fn.getcwd() .. " &"

  local return_signal = vim.fn.jobstart(command, { detach = true })
  utils.log(tostring(return_signal), vim.INFO)
end

return M
