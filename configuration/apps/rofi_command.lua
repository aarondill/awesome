local require = require("util.rel_require")
local rofi_dynamic = require("configuration.rofi_dynamic")

require("configuration.rofi_dynamic", nil, false) -- just in case the rc doesn't import this
local config_file_dir = require(..., "conffile_dir") ---@module "configuration.apps.conffile_dir"

---Create a rofi command
---@param mode string?
---@return string[]
local function rofi_command(mode)
  rofi_dynamic() -- Write config
  -- Thanks to jo148 on github for making rofi dpi aware!
  local xres = require("beautiful").xresources
  -- Ends in -show to pick default, but can be overridden by appending a mode
  local cmd = {
    "rofi",
    "-dpi",
    tostring(xres.get_dpi()),
    "-width",
    tostring(xres.apply_dpi(400)),
    "-theme",
    config_file_dir .. "/rofi/config.rasi",
    "-show",
    mode,
  }
  return cmd
end
return rofi_command
