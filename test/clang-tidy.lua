vim.cmd [[set rtp+=~/Developpement/lua/clang-tidy.nvim]]

RELOAD = require('plenary.reload').reload_module

R = function(name)
  RELOAD(name)
  return require(name)
end

R('clang-tidy').setup()
