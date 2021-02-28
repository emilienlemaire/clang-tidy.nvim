local Job = require('plenary').job
local handlers = require('clang-tidy.handlers')

ClangTidy = {}
ClangTidy.__index = ClangTidy

function ClangTidy:new(opts)

  local this = {
    cmd = opts.cmd,
    args = opts.args,
    cwd = opts.cwd(),
    checks = opts.checks,
    ignore_severity = opts.ignore_severity,
    diagnostics = {},
    old_diagnostics = {},
    current_file = ''
  }

  setmetatable(this, self)

  return this
end

function ClangTidy:get_job()
  local _args = vim.deepcopy(self.args)
  table.insert(_args, self.current_file)
  table.insert(_args, self:_merge_checks())
  self.job = Job:new{
    command = self.cmd,
    args = _args,
    cwd = self.cwd or vim.loop.cwd(),
    enable_handlers = true,
    on_stderr = function(error, data)
      assert(not error, error)
      print(data)
    end,
    on_stdout = handlers.stdout_handler(self),
    on_exit = handlers.exit_handler(self)
  }
  return self.job
end

function ClangTidy:run()
  self:get_job():start()
end

function ClangTidy:_merge_checks()
  local str = "--checks="
  for i, v in ipairs(self.checks) do
    if i == 1 then
      str = str .. v
    else
      str = str .. ',' .. v
    end
  end
  return str
end

function ClangTidy:set_old_diagnostics(old_diagnostics)
  self.old_diagnostics = old_diagnostics
end

function ClangTidy:clear_diagnostics()
  self.diagnostics = {}
end

function ClangTidy:clear_old_diags()
  self.old_diagnostics = {}
end

function ClangTidy:set_current_file(file)
  if type(file) ~= 'string' then
    error("The file path must be a string")
    return
  end
  self.current_file = file
end

return ClangTidy

