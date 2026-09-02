local GdkPixbuf = require("lgi").GdkPixbuf
local cairo = require("lgi").cairo
local capi = require("capi")

---Loads a surface from a file, optionally scaling it
---Keeps the aspect ratio
---@param path string path to the icon
---@param width integer?
---@param height integer?
---@return gears.surface
local function load_surface(path, width, height)
  height, width = height or width, width or height -- if not set, use the other

  local pixbuf, err
  if height then
    pixbuf, err = GdkPixbuf.Pixbuf.new_from_file_at_scale(path, width, height, true)
  else
    pixbuf, err = GdkPixbuf.Pixbuf.new_from_file(path)
  end

  if not pixbuf then error("No pixbuf could be created: " .. tostring(err)) end
  local _surface = capi.awesome.pixbuf_to_surface(pixbuf._native, path)
  local surf = cairo.Surface:is_type_of(_surface) and _surface or cairo.Surface(_surface, true)
  return surf
end

return load_surface
