local M = {}

local config = require("c-unity.config")

---@alias log_data {type:string, id:string, payload:{level:string, timestamp: string,message:string, stack_trace:string, file:string, line: integer}}
---@alias window_data  {buf: integer, win:integer}

---@type {window: window_data}
local state = { window = { buf = -1, win = -1 } }

local function create_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = config.window.filetype
  return buf
end

---Generates a window configuration
---@return vim.api.keyset.win_config
local generate_window_config = function()
  local ui = vim.api.nvim_list_uis()[1]
  local width = ui.width
  local height = ui.height

  local win_width = math.floor(width * config.window.width_perct)
  local win_height = math.floor(height * config.window.height_perct)

  local row = math.floor((height - win_height) / 2)
  local col = math.floor((width - win_width) / 2)

  return {
    style = config.window.style,
    relative = config.window.relative,
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    border = config.window.border,
  }
end

---@param data  window_data
---@param config  vim.api.keyset.win_config
local open_floating_window = function(data, config)
  data = data or {}
  data.win = data.win or {}

  local buf = -1
  if vim.api.nvim_buf_is_valid(data.buf) then
    buf = data.buf
  else
    buf = create_buffer()
  end

  vim.bo[buf].modifiable = false
  local win = vim.api.nvim_open_win(buf, true, config)
  vim.wo[win].number = true

  return { buf = buf, win = win }
end

---@param window_data  { buf:number , win: number }
local function scroll_to_bottom(window_data)
  if not vim.api.nvim_win_is_valid(window_data.win) then return end
  local last_line = vim.api.nvim_buf_line_count(window_data.buf)
  vim.api.nvim_win_set_cursor(window_data.win, { last_line, 0 })
end

---@param buf integer
---@param msg string
local function append_text(buf, msg)
  local lines = vim.split(msg, "\n", { plain = true })

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
  vim.bo[buf].modifiable = false
end

---@param data log_data
local append_log = function(data)
  local buf = state.window.buf
  local lines = { string.format("[%s][%s] %s", data.payload.timestamp, data.payload.level, data.payload.message) }

  if data.payload.stack_trace:len() > 0 then
    local stacktrace = vim.split(data.payload.stack_trace, '\n', { plain = true })
    vim.list_extend(lines, stacktrace)
  end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
  vim.bo[buf].modifiable = false
end


---@param message string
M.append_message = function(message)
  if vim.api.nvim_buf_is_valid(state.window.buf) == false then
    state.window.buf = create_buffer()
  end

  append_text(state.window.buf, message)
end


---Appends the log to the buffer
---@param data log_data
M.append_log = function(data)
  if vim.api.nvim_buf_is_valid(state.window.buf) == false then
    state.window.buf = create_buffer()
  end

  append_log(data)
end

---Clears the log window
M.clear_buffer = function()
  local buf = state.window.buf
  vim.bo[buf].modifiable = true
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
  end
  vim.bo[buf].modifiable = false
end

M.toggle = function()
  if vim.api.nvim_win_is_valid(state.window.win) then
    vim.api.nvim_win_hide(state.window.win)
  else
    local win_config = generate_window_config()
    state.window = open_floating_window(state.window, win_config)
  end
  scroll_to_bottom(state.window)
end

return M
