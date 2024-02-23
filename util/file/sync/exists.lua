local new_file_for_path = require("util.file.new_file_for_path")
--- Return whether a file exists. Syncronously
---@param path string|GFile
---@return boolean
local function exists(path) return new_file_for_path(path):query_exists() end
return exists
