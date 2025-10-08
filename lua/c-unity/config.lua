local config = {}

---@class Config
---@field  debug boolean
---@field loop {timeout: number, repeat_time: number, limit:integer}
---@field connection {server_read_pipe_name: string, server_write_pipe_name: string}


config.debug = true
config.loop = {
  timeout = 1000,
  repeat_time = 1000,
  limit = 100
}

config.connection = {
  server_read_pipe_name = "/tmp/unity-pipe-read",
  server_write_pipe_name = "/tmp/unity-pipe-write"
}

---@param opts Config | nil
config.set = function(opts)
  opts = opts or {}
  config.debug = vim.F.if_nil(opts.debug, config.debug)
  config.loop = vim.F.if_nil(opts.loop, config.loop)
  config.connection = vim.F.if_nil(opts.connection, config.loop)
end



return config
