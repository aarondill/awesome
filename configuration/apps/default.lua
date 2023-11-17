local path = require("util.path")
local require = require("util.rel_require")

local xdg_user_dir = require("util.xdg_user_dir")
local terminal = "wezterm"

-- List of apps to start by default on some actions - Don't use shell features.
---@type (CommandProvider)[]
local default = {
  battery_manager = { "gnome-power-statistics" },
  system_manager = { "gnome-system-monitor" },
  calendar = { "gnome-calendar" },
  -- Above are only used *if* installed
  terminal = { terminal },
  lock = { "sh", "-c", "pgrep -x xss-lock && exec loginctl lock-session || exec lock" }, -- Run loginctl if xss-lock is running, otherwise just lock
  region_screenshot = function()
    local dest = path.join(assert(xdg_user_dir("PICTURES")), "Screenshots")
    assert(require("gears.filesystem").make_directories(dest)) -- Ensure parent directory exists
    return { "flameshot", "gui", "-p", dest }
  end,
  browser = { "vivaldi-stable" },
  editor = { terminal, "-e", "nvim" }, -- gui text editor
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
