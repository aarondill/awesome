local get_filepath = require("util.path.get_filepath")
local gstring = require("gears.string")
local path = require("util.path")

---Turns path like `~/file` into `/home/user/file`
---Note that this path is only useful for output.
---@param filepath string|GFile
---@param sep string the path separator. Default: `path.sep`
---@return string
local function untildify(filepath, sep)
  sep = sep or path.sep
  if not gstring.startswith(filepath, "~" .. sep) then return get_filepath(filepath) end
  local home = path.get_home()
  --- 2 because 1-indexing, +1 for ~, + sep:len()
  local relpath = get_filepath(filepath):sub(2 + sep:len())
  return path.join(home, relpath)
end
return untildify
