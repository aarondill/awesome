---@class wallpaper_config
---@field set string The name of the set of wallpapers to use. This is the name of the directory in /home/aaron/.config/awesome/wallpapers
---@field tags? { [integer]: string? } A table of tags to customize the wallpaper. Normally, this is not needed.

---@type wallpaper_config
local config = {
  set = "B",
}
return config
