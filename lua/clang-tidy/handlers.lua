local utils = require('clang-tidy.utils')
local diagnostics = require('clang-tidy.diagnostics')

local M = {}

function M.stdout_handler(clang_tidy)
  return (function(error, data)
    assert(not error, error)
    local diag = utils.diag_to_table(data)
    if diag and not clang_tidy.ignore_severity[diag.severity] then
      table.insert(clang_tidy.diagnostics, diagnostics.to_lsp_diag(diag))
    end
  end)
end

function M.exit_handler(clang_tidy)
  return vim.schedule_wrap(function()
    if clang_tidy.diagnostics then
      local count = 0
      for _ in pairs(clang_tidy.diagnostics) do
        count = count + 1
      end
      diagnostics.publish_diagnostics(clang_tidy.diagnostics, clang_tidy)
      clang_tidy:set_old_diagnostics(clang_tidy.diagnostics)
      clang_tidy:clear_diagnostics()
      print(string.format("Run clang-tidy with %s diagnostics", count))
    end
  end)
end

function M.publish_diagnostics_handler(clang_tidy)
  return function(_, _, params, client_id, _, config)
    if clang_tidy.old_diagnostics then
      for _, v in pairs(clang_tidy.old_diagnostics) do
        table.insert(params.diagnostics, v)
      end
    end
    local old_table = diagnostics.get_diagnostics_hashtable(clang_tidy.old_diagnostics)
    for i, v in ipairs(params.diagnostics) do
      local hash = utils.hash(v)
      if old_table[hash] then
        table.remove(params.diagnostics, i)
      end
    end
    params.diagnostics = diagnostics.get_unique_diagnostics(params.diagnostics)
    return vim.lsp.diagnostic.on_publish_diagnostics(_, _, params, client_id, _, config)
  end
end

return M
