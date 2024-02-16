local Gio = require("util.lgi.Gio")
local new_file_for_path = require("util.file.new_file_for_path")
---Note: Returns G_FILE_TYPE_UNKNOWN if the file does not exist.
---@param path string|GFile
---@param follow_symlinks boolean? default true
---@return GFileType
local function file_type(path, follow_symlinks)
  follow_symlinks = follow_symlinks == nil and true or follow_symlinks
  local flags = Gio.FileQueryInfoFlags.NONE
  if not follow_symlinks then -- Add NOFOLLOW_SYMLINKS if necessary
    flags = flags & Gio.FileQueryInfoFlags.NOFOLLOW_SYMLINKS
  end
  return new_file_for_path(path):query_file_type(flags)
end
return file_type
