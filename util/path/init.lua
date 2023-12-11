local lgi = require("util.lgi")
local new_file_for_path = require("util.file.new_file_for_path")
local GLib = lgi.GLib
---@diagnostic disable: assign-type-mismatch -- To allow nil values
local M = {
  tildify = nil, ---@module 'util.path.tildify'
  untildify = nil, ---@module 'util.path.untildify'
  get_filepath = nil, ---@module 'util.path.get_filepath'
}
---@diagnostic enable: assign-type-mismatch

---The directory separator as a string. This is “/” on UNIX machines and “\" under Windows.
M.sep = GLib.DIR_SEPARATOR_S ---@type string

---The search path separator as a string. This is “:” on UNIX machines and “;” under Windows.
M.delimiter = GLib.SEARCHPATH_SEPARATOR_S ---@type string

---Joins paths with slashes.
---Usage: path.join({'directory', 'file'}) OR path.join('directory', 'file')
---@param tbl string|string[] note: if a table is passed, remaining arguments are ignored
---@param ... string
---@return string
function M.join(tbl, ...)
  tbl = type(tbl) == "table" and tbl or { tbl, ... }
  return GLib.build_filenamev(tbl)
end

---@param path string
---@return boolean
function M.is_absolute(path)
  return GLib.path_is_absolute(path)
end

---Returns the path normalized to resolve '..' and '.' segments
---Trailing slashes are stripped
---If an empty string is passed, returns ''
---If a relative path is passed and absolute is true, returns an absolute path, using the current working directory
---@param path string the path to normalize
---@param absolute boolean? default: `true`
---@return string
function M.normalize(path, absolute)
  absolute = absolute == nil and true or absolute
  absolute = M.is_absolute(path) and true or absolute -- If given an absolute path, return one, regardless

  local absfile = new_file_for_path(path)
  local abspath = absfile:get_path() --- The normalized absolute path

  if not abspath or abspath == "" then return "" end -- if invalid path, stop handling it

  if absolute then return abspath end
  return M.relative(".", absfile) or abspath
end

---exactly equivalent to path.normalize(path.join(...), true)
---Returns a normalized absolute path
---@param ... string
---@return string
function M.resolve(...)
  return M.normalize(M.join(...), true)
end

---Returns a relative path from `from` to `to`
---Trailing slashes are stripped
---If either `from` or `to` is an empty string or nil, it's treated as the current directory
---@param from? string|GFile
---@param to? string|GFile
---@return string? path nil if no path exists. this should never happen on unix!
function M.relative(from, to)
  from = from ~= "" and from or "." -- Empty strings or nil should be '.'
  to = to ~= "" and to or "." -- Empty strings or nil should be '.'
  local base = new_file_for_path(from)
  local dest = new_file_for_path(to)
  do
    if base:equal(dest) then return "." end -- Given the cwd
    local rel = base:get_relative_path(dest) -- Given a child of the cwd
    if rel then return rel end -- ./directory
  end
  -- ./../../directory
  local pathv = {} ---@type string[]
  local tmp = base ---@type GFile?
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

---Gets the basename and removes an optional suffix
---@param path string
---@param suffix string?
---@return string
function M.basename(path, suffix)
  if not path or path == "" then return "" end
  local basename = GLib.path_get_basename(path)
  if suffix and basename:sub(-suffix:len()) == suffix then
    basename = basename:sub(1, -(suffix:len() + 1)) -- remove the trailing suffix
  end
  return basename
end
---Gets the dirname
---@param path string
---@return string
function M.dirname(path)
  return GLib.path_get_dirname(path)
end
--- The path.extname() method returns the extension of the path, from the last
--- dot to end of string in the last portion of the path.
--- If the path has no extension or begins with a dot (and no other dot), and empty string is returned
---@param path string
---@return string
function M.extname(path)
  return M.basename(path):match(".+(%..+)") or ""
end

--- The path to the root directory
--- '/' on unix. 'C:\' on windows, where C is the current drive
M.root = M.normalize(M.sep, true) ---@type string

local require = require("util.rel_require")
local this_path = ...
return setmetatable(M, {
  __index = function(_, key)
    local m = require(this_path, key, false) -- No TCO!
    return m
  end,
})
