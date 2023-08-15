local filesystem = require("gears.filesystem")

local function rofi_command(...)
  -- Thanks to jo148 on github for making rofi dpi aware!
  local xres = require("beautiful").xresources
  local args = { ... }
  -- Ends in -show to pick default, but can be overridden by appending a mode
  local cmd = {
    "rofi",
    "-dpi",
    tostring(xres.get_dpi()),
    "-width",
    tostring(xres.apply_dpi(400)),
    "-theme",
    filesystem.get_configuration_dir() .. "configuration/rofi/config.rasi",
    "-show",
  }
  for _, v in ipairs(args) do
    table.insert(cmd, v)
  end
  return cmd
end
return rofi_command
