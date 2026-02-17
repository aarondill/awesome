---@class wallpaper_config
---@field set string The name of the set of wallpapers to use. This is the name of the directory in /home/aaron/.config/awesome/wallpapers
---@field tags? { [integer]: string? } A table of tags to customize the wallpaper. Normally, this is not needed.
---Note: This is directly related to the amount of memory AwesomeWM will use
---@field QUALITY_REDUCTION? integer The amount of quality reduction to apply to the wallpaper. Default: 1

---@type wallpaper_config
local config = {
  set = "B",
  QUALITY_REDUCTION = 1,
}
return config
