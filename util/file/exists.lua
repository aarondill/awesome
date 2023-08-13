local gio = require("lgi").Gio
--- Return the name of a file from a path
local function exists(path)
  if not path then return end
  return gio.File.new_for_path(path):query_exists()
end
return exists
