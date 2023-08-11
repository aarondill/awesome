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
    filesystem.get_configuration_dir() .. "configuration/rofi.rasi",
    "-show",
  }
  for _, v in ipairs(args) do
    table.insert(cmd, v)
  end
  return cmd
end

local terminal = "wezterm"

-- List of apps to start by default on some actions - Don't use shell features.
---@type (string|string[])[]
local default = {
  battery_manager = { "xfce4-power-manager-settings" },
  system_manager = { "gnome-system-monitor" },
  calendar = { "gnome-calendar" },
  -- Above are only used *if* installed
  terminal = { terminal },
  rofi = rofi_command(),
  rofi_window = rofi_command("window"),
  lock = { "sh", "-c", "pgrep -x xss-lock && exec loginctl lock-session || exec lock" }, -- Run loginctl if xss-lock is running, otherwise just lock
  region_screenshot = { "flameshot", "gui", "-p", os.getenv("HOME") .. "/Pictures/Screenshots/", "-c" },
  browser = { "vivaldi" },
  editor = { terminal, "-e", "nvim" }, -- gui text editor
  -- social = "discord",
  -- game = "steam",
  -- files = "nautilus",
  -- music = "spotify",
  brightness = {
    up = { "brightnessctl", "set", "10%+", "-e", "-n", "5" },
    down = { "brightnessctl", "set", "10%-", "-e", "-n", "5" },
  },
  volume = {
    up = { "amixer", "-D", "pulse", "sset", "Master", "5%+", "unmute" },
    down = { "amixer", "-D", "pulse", "sset", "Master", "5%-", "unmute" },
    toggle_mute = { "amixer", "-D", "pulse", "sset", "Master", "toggle" },
  },
}

return default
