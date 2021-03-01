vim.cmd [[set rtp+=~/Developpement/lua/clang-tidy.nvim]]

RELOAD = require('plenary.reload').reload_module

R = function(name)
  RELOAD(name)
  return require(name)
end

R('clang-tidy').setup({
  checks = {
    '-*',
    'bugprone-*',
    'cert-*',
    'clang-analyzer-*',
    'cppcoreguidelines-*',
    'hicpp-*',
    'portability-*',
    'misc-*',
    'modernize-*',
    'performance-*',
    'readability-*',
    'fushia-multiple-inheritance',
    'fuchsia-statically-constructed-objects',
    'fuchsia-trailing-return',
    'google-build-using-namespace',
    'google-default-arguments',
    'google-runtime-int',
    'llvm-namespace-comment',
    'llvm-prefer-isa-or-dyn-cast-in-conditionals',
    'llvm-twine-local',
    '-modernize-use-trailing-return-type',
    '-misc-no-recursion'
  }
})
