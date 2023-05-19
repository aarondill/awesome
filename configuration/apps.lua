local filesystem = require("gears.filesystem")

-- Thanks to jo148 on github for making rofi dpi aware!
local with_dpi = require("beautiful").xresources.apply_dpi
local get_dpi = require("beautiful").xresources.get_dpi
local rofi_command = string.format(
	"rofi -dpi '%d' -width '%d' -theme '%s' -show",
	get_dpi(),
	with_dpi(400),
	("%s/configuration/rofi.rasi"):format(filesystem.get_configuration_dir())
)

local terminal = "wezterm"
return {
	-- List of apps to start by default on some actions
	default = {
		terminal = terminal,
		rofi = rofi_command,
		lock = "lock",
		screenshot = "flameshot screen -p ~/Pictures/Screenshots/",
		region_screenshot = "flameshot gui -p ~/Pictures/Screenshots/",
		delayed_screenshot = "flameshot screen -p ~/Pictures/Screenshots/ -d 5000",
		browser = "google-chrome",
		editor = terminal .. " -e nvim", -- gui text editor
		social = "discord",
		game = "steam",
		files = "nautilus",
		music = "spotify",
	},
	-- List of apps to start once on start-up
	run_on_start_up = {
		"dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY", -- Fix gnome apps taking *forever* to open
		"picom --config " .. filesystem.get_configuration_dir() .. "/configuration/picom.conf",
		"nm-applet --indicator", -- wifi
		"blueman-applet", --bluetooth
		"pasystray", -- shows an audiocontrol applet in systray when installed.
		--'blueberry-tray', -- Bluetooth tray icon
		"numlockx on", -- enable numlock
		"/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 & eval $(gnome-keyring-daemon -s --components=pkcs11,secrets,ssh,gpg)", -- credential manager
		-- "xfce4-power-manager", -- Power manager
		-- 'flameshot',
		-- "synology-drive -minimized",
		-- "steam -silent",
		-- "feh --randomize --bg-fill ~/.wallpapers/*",
		-- "/usr/bin/variety",
		-- Add applications that need to be killed between reloads
		-- to avoid multipled instances, inside the awspawn script
		filesystem.get_configuration_dir() .. "configuration/awspawn", -- Spawn "dirty" apps that can linger between sessions
	},
}
