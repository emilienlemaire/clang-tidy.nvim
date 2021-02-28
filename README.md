# clang-tidy.nvim

A small plugin to publish clang-tidy diagnostics via the built in lsp diagnostics.

## Install
This plugin requires `plenary.nvim`
You can use your favorite plugin manager to install this plugin.
With `packer.nvim` :
```lua
use 'nvim-lua/pleanry.nvim'
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
  -- your other attach code
end

lsp.clangd.setup({
  on_attach = custom_attach_clangd,
  -- rest of the setup table
})
```
### Running clang-tidy
TODO
