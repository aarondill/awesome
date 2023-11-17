local lgi = require("lgi")
local Gio, GLib = lgi.Gio, lgi.GLib

---@class Gio.File: userdata
---@field equal fun(self: Gio.File, other: Gio.File): boolean
---@field get_relative_path fun(self: Gio.File, other: Gio.File): string?
---@field get_parent fun(self: Gio.File): Gio.File?
---@field get_path fun(self: Gio.File): string?

local M = {}

---Joins paths with slashes.
---Usage: path.join({'directory', 'file'}) OR path.join('directory', 'file')
---@param tbl string|string[] note: if a table is passed, remaining arguments are ignored
---@param ... string
---@return string
function M.join(tbl, ...)
  tbl = type(tbl) == "table" and tbl or { tbl, ... }
  return GLib.build_filenamev(tbl)
end

---Returns the path normalized to resolve '..' and '.' segments
---Trailing slashes are stripped
---If an empty string is passed, returns nil
---If a relative path is passed and absolute is true, returns an absolute path, using the current working directory
---Note:
---If a Gio.File is passed, an absolute path is returned, because the original path is inaccessible.
---Call relative() to get a relative path if necessary.
---@param path string|Gio.File the path to normalize
---@param absolute boolean? default: `true`
---@return string?
function M.normalize(path, absolute)
  if type(path) == "userdata" then
    absolute = true -- There's no way to recover the path from the passed Gio.File
  elseif type(path) == "string" then
    absolute = absolute == nil and true or absolute
    absolute = path:sub(1, 1) == "/" and true or absolute -- If given an absolute path, return one, regardless
  else
    error("Invalid path", 2)
  end

  local absfile = Gio.File.new_for_path(path)
  local abspath = absfile:get_path() --- The normalized absolute path

  if not abspath then return abspath end -- if invalid path, stop handling it

  if absolute then return abspath end
  return M.relative(".", absfile)
end

---Returns a relative path from `from` to `to`
---Trailing slashes are stripped
---If either `from` or `to` is an empty string or nil, it's treated as the current directory
---@param from? string|Gio.File
---@param to? string|Gio.File
---@return string? path nil if no path exists. this should never happen on unix!
function M.relative(from, to)
  from = from ~= "" and from or "." -- Empty strings or nil should be '.'
  to = to ~= "" and to or "." -- Empty strings or nil should be '.'
  local base = type(from) == "userdata" and from or Gio.File.new_for_path(from)
  local dest = type(to) == "userdata" and to or Gio.File.new_for_path(to)
  do
    if base:equal(dest) then return "." end -- Given the cwd
    local rel = base:get_relative_path(dest) -- Given a child of the cwd
    if rel then return rel end -- ./directory
  end
  -- ./../../directory
  local pathv = {} ---@type string[]
  local tmp = base ---@type Gio.File?
  --- Start with the cwd and progressively go ../ until dest is found under cwd.
  --- If we reach '/' and still don't have a relative path to dest, then return nil.
  --- Note: None of this does any file operations.
  while tmp and not (tmp:get_relative_path(dest) or tmp:equal(dest)) do
    tmp = tmp:get_parent()
    table.insert(pathv, "..")
  end
  -- We reached root and still didn't find it!
  -- There is no relative path between the two files (should never happen! Only on windows?)
  if not tmp then return nil end

  -- The dest is a direct parent of base
  if tmp:equal(dest) then return M.join(pathv) end

  local rel = assert(tmp:get_relative_path(dest), "Could not get relative path: this is a bug!")
  table.insert(pathv, rel)
  return M.join(pathv)
end

return M
