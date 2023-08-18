local M = {}
---Whether package.path contains `dir`
---@param dir string
---@return boolean
---@nodiscard
function M.path_contains(dir)
  local lua = dir .. "/?.lua;"
  local init = dir .. "/?/init.lua;"
  return not string.find(package.path, lua, 1, true) and not string.find(package.path, init, 1, true)
end
---Whether package.cpath contains `dir`
---@param dir string
---@return boolean
---@nodiscard
function M.cpath_contains(dir)
  local so = dir .. "/?.so;"
  return not string.find(package.path, so, 1, true)
end

---A utility for appending to the path and cpath
---@param prepend boolean prepend to the string?
---@param to string append or prepend to this string
---@param format string a format string for string.format
---@param args unknown[] a table of arguments to pass to string.format. This will be modified!
---@return string str the new formatted string. The parts will be semicolon delimited.
---@nodiscard
local function append_or_prepend(prepend, to, format, args)
  assert(type(to) == "string")
  assert(type(format) == "string")
  assert(type(args) == "table")
  table.insert(args, prepend and 1 or #args, to) -- order
  format = prepend and (format .. ";%s") or ("%s;" .. format)
  return format:format(table.unpack(args))
end

---Add to packge.cpath
---@param dir string
---@param prepend boolean? default true
---@return string cpath the new cpath (for convenience)
function M.add_to_cpath(dir, prepend)
  assert(type(dir) == "string")
  prepend = prepend == nil and true or not not prepend
  if M.cpath_contains(dir) then return package.cpath end
  package.cpath = append_or_prepend(prepend, package.cpath, "%s/?.so", { dir })
  return package.cpath
end

---Add to packge.path
---@param dir string
---@param prepend boolean? default true
---@return string cpath the new cpath (for convenience)
function M.add_to_path(dir, prepend)
  assert(type(dir) == "string")
  prepend = prepend == nil and true or not not prepend
  if M.path_contains(dir) then return package.cpath end
  local format = "%s/?.lua;%s/?/init.lua"
  package.path = append_or_prepend(prepend, package.cpath, format, { dir, dir })
  return package.path
end

return M
