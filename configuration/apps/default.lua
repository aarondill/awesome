local terminal = "wezterm"

-- List of apps to start by default on some actions - Don't use shell features.
---@type CommandProvider[]
local default = {
  battery_manager = { "gnome-power-statistics" },
  system_manager = { "gnome-system-monitor" },
  calendar = { "gnome-calendar" },
  -- Above are only used *if* installed
  terminal = { terminal },
  lock = { "sh", "-c", "pgrep -x xss-lock && exec loginctl lock-session || exec lock" }, -- Run loginctl if xss-lock is running, otherwise just lock
  region_screenshot = { "flameshot", "gui" },
  browser = {
    -- The main command to run, it will be passed the below options, followed by `--` and the url(s)
    open = { "vivaldi" },
    incognito = { "--incognito" },
    new_window = { "--new-window" },
  },
  editor = { terminal, "-e", "nvim" }, -- gui text editor
  brightness = {
    up = { "brightnessctl", "set", "10%+", "-e", "-n", "5" },
    down = { "brightnessctl", "set", "10%-", "-e", "-n", "5" },
  },
  volume = {
    up = { "pactl", "set-sink-volume", "@DEFAULT_SINK@", "+5%" },
    down = { "pactl", "set-sink-volume", "@DEFAULT_SINK@", "-5%" },
    toggle_mute = { "pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle" },
    toggle_mic_mute = { "pactl", "set-source-mute", "@DEFAULT_SOURCE@", "toggle" },
    -- up = { "amixer", "sset", "Master", "5%+", "unmute" },
    -- down = { "amixer", "sset", "Master", "5%-", "unmute" },
    -- toggle_mute = { "amixer", "sset", "Master", "toggle" },
    -- toggle_mic_mute = { "amixer", "sset", "Capture", "toggle" },
  },
}

return default
