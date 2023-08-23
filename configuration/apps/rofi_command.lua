local filesystem = require("gears.filesystem")

---create a rofi command
---@param ... string
---@return string[]
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
  for i, v in ipairs(args) do
    if type(v) ~= "string" then error(string.format("Invalid argument #%d. Expected string, got %s", i, type(v))) end
    table.insert(cmd, v)
  end
  return cmd
end
return rofi_command
