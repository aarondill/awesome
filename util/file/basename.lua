local gio = require("lgi").Gio
---Return the basename of a file from a path. This doesn't perform any IO, so it can be called without concern for the event loop.
---@param path string
---@return string
local function basename(path)
  return gio.File.new_for_path(path):get_basename()
end
return basename
