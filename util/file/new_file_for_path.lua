local Gio = require("lgi").Gio
---If a File is passed, it is returned.
---@param path string|GFile
local function new_file_for_path(path)
  if type(path) == "userdata" then return path end
  assert(type(path) == "string", "path must be a string or GFile")
  return Gio.File.new_for_path(path)
end
return new_file_for_path
