local lgi = require("util.lgi")
local GLib = lgi.GLib

---Gets the basename and removes an optional suffix
---@param path string
---@param suffix string?
---@return string
local function basename(path, suffix)
  if not path or path == "" then return "" end
  local bname = GLib.path_get_basename(path)
  if suffix and bname:sub(-suffix:len()) == suffix then
    bname = bname:sub(1, -(suffix:len() + 1)) -- remove the trailing suffix
  end
  return bname
end

return basename
