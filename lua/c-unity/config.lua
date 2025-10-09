local config = {}

---@class Config
---@field  debug boolean
---@field loop {timeout: number, repeat_time: number, limit:integer}
---@field connection {server_read_pipe_name: string, server_write_pipe_name: string, handle_broken_connection: function}
---@field window {border?: 'none'|'single'|'double'|'rounded'|'solid'|'shadow'|string[], width_perct:number, height_perct: number, filetype: string}


config.debug = false
config.loop = {
  timeout = 1000,
  repeat_time = 5000,
  limit = 100
}

config.connection = {
  server_read_pipe_name = "/tmp/unity-pipe-read",
  server_write_pipe_name = "/tmp/unity-pipe-write",
  handle_broken_connection = function() end
}

config.window = {
  filetype = "cunitylog",
  border = "rounded",
  style = "minimal",
  relative = "editor",
  width_perct = 0.8,
  height_perct = 0.8,
}

---@param opts Config | nil
config.set = function(opts)
  opts = opts or {}
  config.debug = vim.F.if_nil(opts.debug, config.debug)
  config.loop = vim.F.if_nil(opts.loop, config.loop)
  config.connection = vim.F.if_nil(opts.connection, config.loop)
  config.window = vim.F.if_nil(opts.window, config.window)
end

return config
