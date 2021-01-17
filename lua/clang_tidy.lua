local Job = require('plenary').job

local args = {
    '-checks="-*,bugprone-*,cppcoreguidelines-avoid-*,readability-identifier-naming,misc-assert-side-effect,readability-container-size-empty*,modernize-*"',
    "--format-style=file",
    "--header-filter='include/*'",
    "-p='.'",
}

table.insert(args, vim.fn.expand("%"))

-- clang-tidy error format:
-- /Path/to/file.cpp:line:col: severity: error message [check-name]
local diag_to_table = function(str)
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
        local str_no_sev = string.sub(str_no_col, idx_msg + 2) -- ignore with space before message

        local idx_check = string.find(str_no_sev, '%[')
        local msg = nil
        local str_no_msg = nil

        local idx_end = nil
        local check = nil

        if idx_check then
            msg = string.sub(str_no_sev, 1, idx_check - 2)
            str_no_msg = string.sub(str_no_sev, idx_check + 1)
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

local severity_to_int = function(severity)
    if severity == "warning" then
        return 2
    elseif severity == "error" then
        return 1
    elseif severity == "note" then
        return 3
    end
end

local to_lsp_diag = function(diag)
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
    severity = severity_to_int(diag["severity"]),
    source = "clang-tidy",
}
end

local publish_diagnostics = function(diagnostics)
    local buf_nr = vim.fn.bufnr()
    local client_id = vim.lsp.buf_get_clients()[1]['id']
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
    vim.lsp.diagnostic.save(diagnostics, buf_nr, client_id)
    vim.lsp.diagnostic.set_signs(diagnostics, buf_nr, client_id)
    vim.lsp.diagnostic.set_underline(diagnostics, buf_nr, client_id)
    vim.lsp.diagnostic.set_virtual_text(diagnostics, buf_nr, client_id)
end

local clang_tidy_diags = {}
local old_diags = {}

function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

local clang_tidy = Job:new{
    command= "clang-tidy",
    args= args,
    cwd = vim.loop.cwd(),
    enable_handlers = true,
    on_stdout = function(error, data)
        if error then
            print(error)
        else
            local diag = diag_to_table(data)
            if diag and diag['severity'] ~= 'note' then
                table.insert(clang_tidy_diags, diag)
            end
        end
    end,
    on_exit = vim.schedule_wrap(function()
        if clang_tidy_diags then
            local lsp_diags = {}
            for _, v in ipairs(clang_tidy_diags) do
                local lsp_diag = to_lsp_diag(v)
                table.insert(lsp_diags, lsp_diag)
            end
            publish_diagnostics(lsp_diags)
            old_diags = lsp_diags
            clang_tidy_diags = {}
        end
    end)
}

local delete_old_diags = function()
    local buf_nr = vim.fn.bufnr()
    local client_id = vim.lsp.buf_get_clients()[1]['id']
    vim.lsp.diagnostic.clear(buf_nr, client_id)
end

return {
    clang_tidy = clang_tidy,
    old_diags = old_diags,
    delete_old_diags = delete_old_diags
}

