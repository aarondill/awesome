local require = require("util.rel_require")

local is_absolute = require(..., "is_absolute") ---@module 'util.path.is_absolute'
local new_file_for_path = require("util.file.new_file_for_path")
local relative = require(..., "relative") ---@module 'util.path.relative'

---Returns the path normalized to resolve '..' and '.' segments
---Trailing slashes are stripped
---If an empty string is passed, returns ''
---If a relative path is passed and absolute is true, returns an absolute path, using the current working directory
---@param path string the path to normalize
---@param absolute boolean? default: `true`
---@return string
local function normalize(path, absolute)
  absolute = absolute == nil and true or absolute
  absolute = is_absolute(path) and true or absolute -- If given an absolute path, return one, regardless

  local absfile = new_file_for_path(path)
  local abspath = absfile:get_path() --- The normalized absolute path

  if not abspath or abspath == "" then return "" end -- if invalid path, stop handling it

  if absolute then return abspath end
  return relative(".", absfile) or abspath
end

return normalize
