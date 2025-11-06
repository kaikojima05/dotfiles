if vim.loader then
  vim.loader.enable()
end

_G.dd = function(...)
  require("util.debug").dump(...)
end
vim.print = _G.dd
vim.env.XDG_STATE_HOME = "/tmp"

require("config.lazy")
