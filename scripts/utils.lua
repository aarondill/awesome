local M = {}
---@class _Log
M.log = {}
---@param msg string
---@param format string
---@param output file*
local function _log(msg, format, output)
  local indented = msg:gsub("\n", "\n  ")
  local formatted = (format):format(indented) .. "\n"
  output:write(formatted)
end
---@param msg string
function M.log.error(msg) return _log(msg, "ERROR: %s", io.stderr) end
---@param msg string
function M.log.warn(msg) return _log(msg, "WARNING: %s", io.stderr) end
---@type fun(msg: string, exit_code?: number)
function M.log.abort(msg, exit_code)
  M.log.error(msg)
  os.exit(exit_code or 1)
end
---@param fmt string
function M.printf(fmt, ...) print(string.format(fmt, ...)) end

---Nicer output for assert, no stack trace
---Note: this can't be log.assert, since assert it a special function name to LuaLS
---@generic T
---@param cond T|nil|false
---@param msg unknown?
---@param ... unknown
---@return T
---@return unknown ...
function M.assert(cond, msg, ...)
  if not cond then
    M.log.abort(tostring(msg) or "assertion failed!")
    _G.assert(false, "BUG: unreachable")
  end
  return cond, msg, ...
end

---Concatenates all tables and returns the result
---@generic T : unknown[]
---@param ... T
---@return T
function M.table_concat(...)
  local dest = { n = 0 }
  for i = 1, select("#", ...) do
    local t1_len = dest.n or #dest
    local source = select(i, ...) or {} ---@type unknown[]|{n?: number}
    local source_len = source.n or #source
    table.move(source, 1, source_len, t1_len + 1, dest)
    if dest.n then -- if a length is already set, then we need to update it
      dest.n = dest.n + source_len
    end
  end
  return dest
end
---Merges all tables into one, keeping the last value
---@param ... table
---@return table
function M.table_merge(...)
  local dest = {}
  for i = 1, select("#", ...) do
    local source = select(i, ...) or {} ---@type unknown[]|{n?: number}
    for k, v in pairs(source) do
      dest[k] = v
    end
  end
  return dest
end

---@generic K
---@param t table<K, unknown>
---@return K[]
function M.table_keys(t)
  local keys = {}
  for k in pairs(t) do
    table.insert(keys, k)
  end
  return keys
end

---@param cmd string[]
---@param opts? {cwd?: string}
---@return GSubprocess
function M.spawn(cmd, opts)
  local Gio = require("lgi").Gio
  opts = opts or {}
  local launcher = Gio.SubprocessLauncher.new(Gio.SubprocessFlags.STDIN_INHERIT)
  if opts.cwd then launcher:set_cwd(opts.cwd) end
  return assert(launcher:spawnv(cmd))
end

---Stringifies a table of commands/args.
---Quotes each one and seperates them with delim
---@param args string[] | string A string is treated as a single argument
---@param delim? string default ' '
---@return string escaped
function M.shell_escape(args, delim)
  if type(args) == "string" then args = { args } end
  local output = {}
  table.move(args, 1, #args, #output + 1, output)
  for i, arg in ipairs(args) do
    if arg:match("[^A-Za-z0-9_/:-]") then -- If contains special chars
      local escaped = arg:gsub("'", "'\\''")
      output[i] = table.concat({ "'", escaped, "'" }, "")
    end
  end
  return table.concat(output, delim or " ")
end

---@param action string
---@param cmd string[]
---@param opts? {cwd?: string}
function M.spawn_check(action, cmd, opts)
  M.printf("Running %s...", action)
  M.printf("> %s", M.shell_escape(cmd))
  local proc = M.spawn(cmd, opts)
  local ok, err = proc:wait_check()
  assert(ok, ("Command failed: %s"):format(action, err))
end

return M
