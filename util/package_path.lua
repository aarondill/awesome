local M = {}
---@param path string
---@return string
local function cleanup_path(path)
  ---@type string
  local res = path
  res = res:gsub("/%./", "/") -- no /./
  res = res:gsub("^(.+)/$", "%1") -- no end slash -- use .+ instead of .* to keep '/' instead of ''
  res = res:gsub("//+", "/") -- no double slashes
  local count = -1
  while count ~= 0 do
    res, count = res:gsub("^/%.%./", "/") -- remove /../ at root level
  end
  return res
end
---Whether package.path contains `dir`
---@param dir string
---@return boolean
---@nodiscard
function M.path_contains(dir)
  dir = cleanup_path(assert(dir))
  local lua = ";" .. dir .. "/?.lua;"
  local init = ";" .. dir .. "/?/init.lua;"
  local path_cmp = ";" .. package.path .. ";" -- package.path may not end in a semicolon. Likely won't start with one.
  return not not (string.find(path_cmp, lua, 1, true) and string.find(path_cmp, init, 1, true))
end
---Whether package.cpath contains `dir`
---@param dir string
---@return boolean
---@nodiscard
function M.cpath_contains(dir)
  dir = cleanup_path(assert(dir))
  local so = ";" .. dir .. "/?.so;"
  local path_cmp = ";" .. package.cpath .. ";" -- package.cpath may not end in a semicolon. Likely won't start with one.
  return not not string.find(path_cmp, so, 1, true)
end

---A utility for appending to the path and cpath
---@param prepend boolean prepend to the string?
---@param to string append or prepend to this string
---@param format string a format string for string.format
---@param args unknown[] a table of arguments to pass to string.format. This will be modified!
---@return string str the new formatted string. The parts will be semicolon delimited.
---@nodiscard
---@implenote prepend refers to the template to-to, no to-to the template
local function append_or_prepend(prepend, to, format, args)
  assert(type(to) == "string")
  assert(type(format) == "string")
  assert(type(args) == "table")
  table.insert(args, prepend and (#args + 1) or 1, to) -- order
  format = prepend and (format .. ";%s") or ("%s;" .. format)
  return format:format(table.unpack(args))
end

---Add to packge.cpath
---@param dir string
---@param prepend boolean? default true
---@return string cpath the new cpath (for convenience)
function M.add_to_cpath(dir, prepend)
  dir = cleanup_path(assert(dir))
  assert(type(dir) == "string")
  prepend = prepend == nil and true or not not prepend
  if M.cpath_contains(dir) then return package.cpath end
  package.cpath = append_or_prepend(prepend, package.cpath, "%s/?.so", { dir })
  return package.cpath
end

---Add to packge.path
---@param dir string
---@param prepend boolean? default true
---@return string path the new path (for convenience)
function M.add_to_path(dir, prepend)
  dir = cleanup_path(assert(dir))
  assert(type(dir) == "string")
  prepend = prepend == nil and true or not not prepend
  if M.path_contains(dir) then return package.path end
  local format = "%s/?.lua;%s/?/init.lua"
  package.path = append_or_prepend(prepend, package.path, format, { dir, dir })
  return package.path
end

return M
