local find_home = require("util.find_home")
local get_filepath = require("util.path.get_filepath")
local new_file_for_path = require("util.file.new_file_for_path")
local path = require("util.path")

---Turns path like `/home/user/file` into `~/file`
---Note that this path is only useful for output.
---@param filepath string|GFile
---@return string
local function tildify(filepath)
  local home = new_file_for_path(find_home())
  local file = new_file_for_path(filepath)
  local relpath = home:get_relative_path(file)

  if not relpath then return get_filepath(filepath) end

  return path.join("~", relpath)
end

return tildify
