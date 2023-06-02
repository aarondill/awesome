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

-- List of apps to start by default on some actions - Don't use shell features.
local default = {
	battery_manager = "xfce4-power-manager-settings",
	system_manager = "gnome-system-monitor",
	calendar = "gnome-calendar",
	-- Above are only used *if* installed
	terminal = terminal,
	rofi = rofi_command,
	rofi_window = rofi_command .. " window",
	lock = "sh -c 'pgrep -x xss-lock && exec loginctl lock-session || exec lock'", -- Run loginctl if xss-lock is running, otherwise just lock
	region_screenshot = "flameshot gui -p ~/Pictures/Screenshots/ -c",
	browser = "google-chrome --enable-features=WebUIDarkMode --force-dark-mode",
	editor = terminal .. " -e nvim", -- gui text editor
	-- social = "discord",
	-- game = "steam",
	-- files = "nautilus",
	-- music = "spotify",
	brightness = {
		up = "brightnessctl set 10%+ -e -n 5",
		down = "brightnessctl set 10%- -e -n 5",
	},
	volume = {
		up = "amixer -D pulse sset Master 5%+ unmute",
		down = "amixer -D pulse sset Master 5%- unmute",
		toggle_mute = "amixer -D pulse sset Master toggle",
	},
}

-- List of apps to start once on start-up - these will (obviosly) only run if available, but no errors will occur if they aren't.
-- These will be run in sh. Don't use any weird syntax (bashisms). If the command line includes a space, it will *not* be
-- exec'ed, you should do it yourelf.
local run_on_start_up = {
	"exec dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY 2>/dev/null", -- Fix gnome apps taking *forever* to open
	'exec /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 & eval \\"$(gnome-keyring-daemon -s --components=pkcs11,secrets,ssh,gpg)\\"', -- credential manager
	string.format("exec picom --config '%s/configuration/picom.conf'", filesystem.get_configuration_dir()),
	"diodon", -- Clipboard after closing window
	"exec nm-applet --indicator", -- wifi
	"blueman-applet", --bluetooth
	"pasystray", -- shows an audiocontrol applet in systray when installed.
	"exec xfce4-power-manager", -- Power manager
	"exec xautolock -time 15 -locker lock -notify 20 -notifier 'notify-send \"screen will lock in 20 secs\"' -secure || exec xss-lock -- lock", -- Autolock
	string.format("sleep 1 && exec udiskie -c '%s/configuration/udiskie.yml'", filesystem.get_configuration_dir()), -- Automount disks.
	-- Sleep to ensure it's last. My own preference. Feel free to remove it
	"sleep 1.5 && exec ibus-daemon --xim -rd", -- Run ibus-daemon for language and emoji keyboard support
	"exec systemd-inhibit --what handle-power-key --who awesome --why 'to enable custom power key handling' --mode block sleep infinity",
	"exec /usr/lib/notification-daemon/notification-daemon -r",
	-- "/usr/libexec/deja-dup/deja-dup-monitor", -- Run backups using deja-dup on timer
	-- Add applications that need to be killed between reloads
	-- to avoid multipled instances, inside the awspawn script
	string.format("exec '%s/configuration/awspawn'", filesystem.get_configuration_dir()), -- Spawn "dirty" apps that can linger between sessions
}
return { default = default, run_on_start_up = run_on_start_up }
