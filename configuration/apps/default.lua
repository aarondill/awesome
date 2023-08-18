local require = require("util.rel_require")

local rofi_command = require(..., "rofi_command") ---@module "configuration.apps.rofi_command"
local xdg_user_dir = require("util.xdg_user_dir")
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
  region_screenshot = { "flameshot", "gui", "-p", xdg_user_dir("PICTURES") .. "/Screenshots", "-c" },
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
