local M = {}


-- clang-tidy error format:
-- /Path/to/file.cpp:line:col: severity: error message [check-name]
function M.diag_to_table(str)
  if string.sub(str,1,1) == "/" then
    local idx_line = string.find(str, ":")
    local str_no_path = string.sub(str, idx_line + 1)

    local idx_col = string.find(str_no_path, ":")
    local line = string.sub(str_no_path, 1, idx_col - 1)
    local str_no_line = string.sub(str_no_path, idx_col + 1)

    local idx_sev = string.find(str_no_line, ":")
    local col = string.sub(str_no_line, 1, idx_sev - 1)
    local str_no_col = string.sub(str_no_line, idx_sev + 2) -- ignore white space before severity

    local idx_msg = string.find(str_no_col, ":")
    local severity = string.sub(str_no_col, 1, idx_msg - 1)
    local str_no_sev = string.sub(str_no_col, idx_msg + 2) -- ignore white space before message

    local idx_check = string.find(str_no_sev, '%[[%l%-]+%]$')
    local msg = nil
    local str_no_msg = nil

    local idx_end = nil
    local check = nil

    if idx_check then
      msg = string.sub(str_no_sev, 1, idx_check - 2)
      str_no_msg = string.sub(str_no_sev, idx_check + 1)
      print(str_no_msg)
      idx_end = string.find(str_no_msg, '%]')
      check = string.sub(str_no_msg, 1, idx_end - 1)
    else
      msg = str_no_sev
    end

    return {
      line = tonumber(line) - 1,
      col = tonumber(col),
      severity = severity,
      message = msg,
      check = check,
    }
  end
end

function M.severity_to_int(severity)
  if severity == "warning" then
    return 2
  elseif severity == "error" then
    return 1
  elseif severity == "note" then
    return 3
  end
end

function M.Set(list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

function M.merge_opts(user_opts)
  local defaults = {
    cmd = 'clang-tidy',
    checks = {
      '*'
    },
    args = {},
    cwd = vim.loop.cwd,
    ignore_severity = {
      'note'
    }
  }
  if user_opts then
    for k, v in pairs(user_opts) do
      defaults[k] = v
    end
  end
  return defaults
end

function M.hash(diagnostic)
  if not diagnostic.range then
    local diagnostics = require("clang-tidy.diagnostics")
    error("____FAIL____")
    print(vim.inspect(diagnostic))
    diagnostic = diagnostics.to_lsp_diag(diagnostic)
    print("___REPAIR___")
    print(vim.inspect(diagnostic))
  end
  local str = diagnostic.code
  local start = diagnostic.range.start
  local end_ = diagnostic.range['end']
  str = str .. "." .. start.line .. ":" ..start.character
  str = str .. "." .. end_.line .. ":" .. end_.character
  return str
end

return M
