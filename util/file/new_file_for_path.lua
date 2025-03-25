local lgi = require("lgi")
local Gio, GObject = lgi.Gio, lgi.GObject
---If a File is passed, it is returned.
---@param path string|GFile
---@return GFile
local function new_file_for_path(path)
  if GObject.Object:is_type_of(path) then --- There's no better way to check for GFile
    assert(type(path) == "userdata", "a GFile was somehow not a userdata")
    return path
  end
  assert(type(path) == "string", "path must be a string or GFile")
  return Gio.File.new_for_path(path)
end
return new_file_for_path
