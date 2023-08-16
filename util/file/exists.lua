local gio = require("lgi").Gio
--- Return whether a file exists. Syncronously
---@param path string?
---@return boolean
local function exists(path)
  if not path then return false end
  return gio.File.new_for_path(path):query_exists()
end
return exists
