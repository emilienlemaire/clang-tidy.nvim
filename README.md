# clang-tidy.nvim

A small plugin to publish clang-tidy diagnostics via the built in lsp diagnostics.

## Install
This plugin requires `plenary.nvim`
You can use your favorite plugin manager to install this plugin.
With `packer.nvim` :
```lua
use 'nvim-lua/plenary.nvim'
use 'emilienlemaire/clang-tidy.nvim'
```

## Usage
### Configuration
I recommand using this plugin only in buffer with `clangd` activated.
You can setup a custom attach function for `clangd`.
```lua
local clang_tidy = require('clang-tidy')

local custom_attach_clangd = function(client)
  clang_tidy.setup()
  -- rest of the attch function
end

lsp.clangd.setup({
  on_attach = custom_attach_clangd,
  -- rest of the setup table
})
```

### Custom configuration
You can confure clang-tidy as you wish in the `setup` function arguments:
```lua
require('clang-tidy').setup{
  checks = {
    '-*',
    'bugprone-*',
    'cppcoreguidelines-avoid-*',
    'readability-identifier-naming',
    'misc-assert-side-effect',
    'readability-container-size-empty-*',
    'modernize-*'
  },
  ignore_severity = {}
}
```
Here is the default configuration:
```lua
{
  cmd = 'clang-tidy', -- The clang-tidy command
  checks = {'*'}, -- An array of clang-tidy checks
  args = {}, -- An array clang-tidy launching args
  cwd = vim.loop.cwd, -- Function: the function to execute to get the cwd
  ignore_severity = {
    'note'
  } -- An array of severity that you don't wish to publish
}
```

### Running clang-tidy
You can run the clang-tidy plugin with:
```lua
require('clang-tidy').run()
```
