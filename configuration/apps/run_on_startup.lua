local require = require("util.rel_require")

local Gio = require("lgi").Gio
local config_file_dir = require(..., "conffile_dir") ---@module "configuration.apps.conffile_dir"
local gfile = require("gears.filesystem")
local path = require("util.path")

local polkit = "/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1"
if not gfile.file_executable(polkit) then polkit = "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1" end
local ENVIRONMENT_EXPORT = { "XDG_CURRENT_DESKTOP", "DBUS_SESSION_BUS_ADDRESS", "DISPLAY", "XAUTHORITY" }
local pasystray_notify_options = {
  ---Exclude 'new'
  "--notify=none",
  "--notify=sink",
  "--notify=sink_default",
  "--notify=source",
  "--notify=source_default",
  "--notify=stream",
  "--notify=stream_output",
  "--notify=stream_input",
  "--notify=systray_action",
}

-- List of apps to start once on start-up - these will (obviously) only run if available, but no errors will occur if they aren't.
-- These can be tables or strings. They will *not* be run in a shell, so you must invoke it yourself if you so desire.
-- Using a table is safer because quoting isn't an issue
---@type CommandProvider[]
local run_on_startup = {
  { "systemctl", "--user", "import-environment", table.unpack(ENVIRONMENT_EXPORT) },
  { "dbus-update-activation-environment", table.unpack(ENVIRONMENT_EXPORT) }, -- Fix gnome apps taking *forever* to open
  { "xsettingsd", "-c", path.resolve(config_file_dir, "xsettingsd.conf") },
  { polkit }, -- Authentication popup
  { "xoop", "-x" }, -- Start xoop to allow wrapping the screen (on x axis)
  "diodon", -- Clipboard after closing window
  "nm-applet", -- wifi
  "blueman-applet", --bluetooth
  { "pasystray", "--no-icon-tooltip", table.unpack(pasystray_notify_options) }, -- shows an audiocontrol applet in systray when installed.
  "xset s 0 0", -- disable screen saver
  "xset -dpms", -- Disable dpms because doesn't work with keys?
  { "xss-lock", "-q", "-l", "--", "lock" }, -- Lock on suspend or dpms
  "numlockx on",
  { "udiskie", "-q", "-c", path.resolve(config_file_dir, "udiskie.yml") }, -- Automount disks.
  "ibus-daemon --xim -d", -- Run ibus-daemon for language and emoji keyboard support
  { "redshift", "-P" }, -- this uses the system configuration -- reset the gamma settings before applying
  { "protonvpn-app", "--start-minimized" }, -- Start VPN tray
  -- { "hp-systray" }, -- Ensure HP printer software is active.
  -- "/usr/libexec/deja-dup/deja-dup-monitor", -- Run backups using deja-dup on timer
  -- Add applications that need to be killed between reloads
  -- to avoid multipled instances, inside the awspawn script
  { path.resolve(gfile.get_configuration_dir(), "scripts", "awspawn") }, -- Spawn "dirty" apps that can linger between sessions
}

---Note: this is already escaped
---This is some evil synchronise code, but it's needed to ensure that we have a touch pad to play with
local libinput_gestures_conf = path.resolve(config_file_dir, "libinput-gestures.conf")
local cmd = { "libinput-gestures", "--conffile", libinput_gestures_conf, "--list" }
local p = assert(Gio.Subprocess.new(cmd, Gio.SubprocessFlags.STDOUT_SILENCE | Gio.SubprocessFlags.STDERR_PIPE))
local stderr = Gio.DataInputStream.new(assert(p:get_stderr_pipe()))
if stderr:read_line() ~= "Could not determine touchpad device." then
  -- Enable touch gesture support
  table.insert(run_on_startup, { "libinput-gestures", "--conffile", libinput_gestures_conf })
end
stderr:close_async(0)

return run_on_startup
