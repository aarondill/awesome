local filesystem = require("gears.filesystem")

-- Thanks to jo148 on github for making rofi dpi aware!
local xres = require("beautiful").xresources
-- Ends in -show to pick default, but can be overridden by appending a mode
local rofi_command = string.format(
	"rofi -dpi '%d' -width '%d' -theme '%s' -show",
	xres.get_dpi(),
	xres.apply_dpi(400),
	("%s/configuration/rofi.rasi"):format(filesystem.get_configuration_dir())
)
local terminal = "wezterm"

-- List of apps to start by default on some actions
local default = {
	battery_manager = "xfce4-power-manager-settings", -- Only used *if* installed
	terminal = terminal,
	rofi = rofi_command,
	rofi_window = rofi_command .. " window",
	lock = "lock",
	region_screenshot = "flameshot gui -p ~/Pictures/Screenshots/ -c",
	browser = "google-chrome",
	editor = terminal .. " -e nvim", -- gui text editor
	social = "discord",
	game = "steam",
	files = "nautilus",
	music = "spotify",
}

-- List of apps to start once on start-up - these will (obviosly) only run if available, but no errors will occur if they aren't.
local run_on_start_up = {
	"dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY", -- Fix gnome apps taking *forever* to open
	"picom --config " .. filesystem.get_configuration_dir() .. "/configuration/picom.conf",
	"nm-applet --indicator", -- wifi
	"blueman-applet", --bluetooth
	"pasystray", -- shows an audiocontrol applet in systray when installed.
	"numlockx on", -- enable numlock
	"/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 & eval $(gnome-keyring-daemon -s --components=pkcs11,secrets,ssh,gpg)", -- credential manager
	"xfce4-power-manager", -- Power manager
	"ibus-daemon --xim -rd", -- Run ibus-daemon for language and emoji keyboard support
	-- "steam -silent",
	-- Add applications that need to be killed between reloads
	-- to avoid multipled instances, inside the awspawn script
	filesystem.get_configuration_dir() .. "configuration/awspawn", -- Spawn "dirty" apps that can linger between sessions
}
return { default = default, run_on_start_up = run_on_start_up }
