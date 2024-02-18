local new_file_for_path = require("util.file.new_file_for_path")
---Note: Returns "UNKNOWN" if the file does not exist.
---@param path string|GFile
---@param follow_symlinks boolean? default true
---@return GFileType
local function file_type(path, follow_symlinks)
  follow_symlinks = follow_symlinks == nil and true or follow_symlinks
  return new_file_for_path(path):query_file_type(follow_symlinks and "NONE" or "NOFOLLOW_SYMLINKS")
end
return file_type
