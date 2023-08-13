local gio = require("lgi").Gio
---Return the basename of a file from a path
---@param path string
---@return string
local function basename(path)
  return gio.File.new_for_path(path):get_basename()
end
return basename
