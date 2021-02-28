local utils = require('clang-tidy.utils')
local M = {}

function M.to_lsp_diag(diag)
  return {
    code = diag['check'],
    message = diag['message'],
    range = {
      start = {
        character = diag['col'],
        line = diag['line']
      },
      ['end'] = {
        character = diag['col'],
        line = diag['line']
      },
    },
    severity = utils.severity_to_int(diag["severity"]),
    source = "clang-tidy",
  }
end

function M.publish_diagnostics(diagnostics, clang_tidy)
  local buf_nr = vim.fn.bufnr()
  local client_id
  if vim.lsp.buf_get_clients(buf_nr)[1]['id'] then
    client_id = vim.lsp.buf_get_clients(buf_nr)[1]['id']
  else
    return
  end
  local curr_diags = vim.lsp.diagnostic.get()
  for _, v in ipairs(curr_diags) do
    table.insert(diagnostics, v)
  end
  for i, v in ipairs(diagnostics) do
    if v.range == nil then
      local diag = v[1]
      table.remove(diagnostics, i)
      table.insert(diagnostics, diag)
    end
  end
  local old_table = M.get_diagnostics_hashtable(clang_tidy.old_diagnostics)
  for i, v in ipairs(diagnostics) do
    local hash = utils.hash(v)
    if old_table[hash] then
      table.remove(diagnostics, i)
    end
  end
  diagnostics = M.get_unique_diagnostics(diagnostics)
  vim.lsp.diagnostic.clear(buf_nr, client_id)
  vim.lsp.diagnostic.save(diagnostics, buf_nr, client_id)
  vim.lsp.diagnostic.set_signs(diagnostics, buf_nr, client_id)
  vim.lsp.diagnostic.set_underline(diagnostics, buf_nr, client_id)
  vim.lsp.diagnostic.set_virtual_text(diagnostics, buf_nr, client_id)
end

function M.get_unique_diagnostics(diagnostics)
  local hashtable = M.get_diagnostics_hashtable(diagnostics)

  local unique_diagnostics = {}
  for _, diag in pairs(hashtable) do
    table.insert(unique_diagnostics, diag)
  end
  return unique_diagnostics
end

function M.get_diagnostics_hashtable(diagnostics)
  local hashtable = {}
  for _, diag in ipairs(diagnostics) do
    local hash = utils.hash(diag)
    hashtable[hash] = diag
  end
  return hashtable
end

return M
