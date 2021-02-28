local utils = require('clang-tidy.utils')
local handlers = require('clang-tidy.handlers')
local ClangTidy = require('clang-tidy.clang_tidy')
local M = {}

M.clang_tidy = {}

function M.setup(opts)
  M.clang_tidy = ClangTidy:new(utils.merge_opts(opts))
  vim.lsp.handlers["textDocument/publishDiagnostics"] = handlers.publish_diagnostics_handler(M.clang_tidy)
end

function M.run()
  local relative_path = vim.fn.expand("%")
  local buf_nr = vim.api.nvim_get_current_buf()
  local client_id = vim.lsp.buf_get_clients(buf_nr)[1]['id']
  vim.lsp.diagnostic.clear(buf_nr, client_id)
  M.clang_tidy:clear_diagnostics()
  M.clang_tidy:set_current_file(relative_path)
  local job = M.clang_tidy:get_job()
  job:start()
end

return M
