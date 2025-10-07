local M = {}

---@alias log_data {type:string, id:string, payload:{level:string, timestamp: string,message:string, stack_trace:string, file:string, line: integer}}


local state = { floating = { buf = -1, win = -1 } }
-- Function to open a floating window
local function open_floating_window(opts)
  opts = opts or {}
  -- Get the editor dimensions
  local ui = vim.api.nvim_list_uis()[1]
  local width = ui.width
  local height = ui.height

  -- Desired window size (80% width, some height ratio)
  local win_width = math.floor(width * 0.8)
  local win_height = math.floor(height * 0.8)

  -- Center the window
  local row = math.floor((height - win_height) / 2)
  local col = math.floor((width - win_width) / 2)

  local buf = -1
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true)
  end


  vim.bo[buf].modifiable = false

  -- Window options
  local window_opts = {
    style = "minimal",
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    border = "rounded", -- you can use "single", "double", "shadow", etc.
  }


  -- Open the floating window
  local win = vim.api.nvim_open_win(buf, true, window_opts)
  vim.wo[win].number = true

  return { buf = buf, win = win }
end

local function scroll_to_bottom(buf, win)
  if not vim.api.nvim_win_is_valid(win) then return end
  local last_line = vim.api.nvim_buf_line_count(buf)
  -- Move cursor to last line (1-indexed)
  vim.api.nvim_win_set_cursor(win, { last_line, 0 })
end

local function append_text(buf, msg)
  -- Split msg into lines (preserve multiple lines)
  local lines = vim.split(msg, "\n", { plain = true })

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
  vim.bo[buf].modifiable = false
end

M.toggle = function()
  if vim.api.nvim_win_is_valid(state.floating.win) then
    vim.api.nvim_win_hide(state.floating.win)
  else
    state.floating = open_floating_window { buf = state.floating.buf }
  end
end

---@param message string
M.append_message = function(message)
  if vim.api.nvim_buf_is_valid(state.floating.buf) == false then
    state.floating.buf = vim.api.nvim_create_buf(false, true)
  end

  append_text(state.floating.buf, message)
end

---@param data log_data
M.append_log = function(data)
  if vim.api.nvim_buf_is_valid(state.floating.buf) == false then
    state.floating.buf = vim.api.nvim_create_buf(false, true)
  end
  local buf = state.floating.buf

  local lines = { string.format("[%s][%s]: %s", data.payload.timestamp, data.payload.level, data.payload.message) }

  if data.payload.stack_trace:len() > 0 then
    local stacktrace = vim.split(data.payload.stack_trace, '\n', { plain = true })
    vim.list_extend(lines, stacktrace)
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
  vim.bo[buf].modifiable = false
end


return M
