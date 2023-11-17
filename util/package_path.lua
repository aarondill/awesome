local sep = ";"

local assert_util = require("util.assert_util") -- This has no requires
local gtable = require("gears.table")
local notifs = require("util.notifs")
local path = require("util.path") -- This only requires lgi
local strings = require("util.strings")

local M = {}
---Whether package.path contains `dir`
---@param dir string
---@return boolean
---@nodiscard
function M.path_contains(dir)
  assert_util.type(dir, "string", "dir")
  dir = path.normalize(dir, false)
  local lua = table.concat({ sep, path.join(dir, "?.lua"), sep }, "")
  local init = table.concat({ sep, path.join(dir, "?", "init.lua"), sep }, "")
  -- package.path may not end in a semicolon. Likely won't start with one.
  local path_cmp = table.concat({ sep, package.path, sep }, "")
  return not not (string.find(path_cmp, lua, 1, true) and string.find(path_cmp, init, 1, true))
end
---Whether package.cpath contains `dir`
---@param dir string
---@return boolean
---@nodiscard
function M.cpath_contains(dir)
  assert_util.type(dir, "string", "dir")
  dir = path.normalize(dir, false)
  local so = table.concat({ sep, path.join(dir, "?.so"), sep }, "")
  -- package.cpath may not end in a semicolon. Likely won't start with one.
  local path_cmp = table.concat({ sep, package.cpath, sep }, "")
  return not not string.find(path_cmp, so, 1, true)
end

---Add to packge.cpath
---@param dir string
---@param prepend boolean? default true
---@return string cpath the new cpath (for convenience)
function M.add_to_cpath(dir, prepend)
  assert_util.type(dir, "string", "dir")
  dir = path.normalize(dir)
  prepend = prepend == nil and true or not not prepend
  if M.cpath_contains(dir) then return package.cpath end
  local new = { package.cpath, path.join(dir, "?.so") }
  if prepend then new = gtable.reverse(new) end
  package.cpath = table.concat(new, sep)
  return package.cpath
end

---Add to packge.path
---@param dir string
---@param prepend boolean? default true
---@return string path the new path (for convenience)
function M.add_to_path(dir, prepend)
  assert_util.type(dir, "string", "dir")
  dir = path.normalize(dir)
  prepend = prepend == nil and true or not not prepend
  if M.path_contains(dir) then return package.path end
  local new = { package.path, path.join(dir, "?.lua"), path.join(dir, "?", "init.lua") }
  if prepend then new = gtable.reverse(new) end
  package.path = table.concat(new, sep)
  return package.path
end

---Remove duplicate paths from packge.path
---Keeps the first one.
---@param force boolean? default: false. Should remove relative and absolute paths that refer to the same path?
function M.dedupe(force)
  force = not not force
  local res = {}
  local seen = {} -- Already found this one
  for _, p in ipairs(strings.split(package.path, sep)) do
    local normal = path.normalize(p, force) -- If force, consider all paths as absolute, else keep relative paths
    if not seen[normal] then
      seen[normal] = true
      table.insert(res, p) -- Keep the original path
    end
  end
  package.path = table.concat(res, sep)
  return package.path
end

return M
