local filesystem = require("gears.filesystem")
local notification_daemon = "/usr/lib/notification-daemon-1.0/notification-daemon"
if not filesystem.file_executable(notification_daemon) then
  notification_daemon = "/usr/lib/notification-daemon/notification-daemon"
end

local polkit = "/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1"
if not filesystem.file_executable(polkit) then polkit = "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1" end

-- List of apps to start once on start-up - these will (obviosly) only run if available, but no errors will occur if they aren't.
-- These can be tables or strings. They will *not* be run in a shell, so you must invoke it yourself if you so desire.
-- Using a table is safer because quoting isn't an issue
local run_on_startup = {
  "dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY", -- Fix gnome apps taking *forever* to open
  { polkit }, -- Authentication popup
  { "picom", "--config", filesystem.get_configuration_dir() .. "configuration/picom.conf" },
  "diodon", -- Clipboard after closing window
  "nm-applet", -- wifi
  "blueman-applet", --bluetooth
  { "sh", "-c", "pasystray --no-icon-tooltip >~/.cache/pasystray-output.log 2>&1" }, -- shows an audiocontrol applet in systray when installed.
  -- "exec xfce4-power-manager", -- Power manager
  "xset s 0 0", -- disable screen saver
  "xset -dpms", -- Disable dpms because doesn't work with keys?
  "xss-lock -- lock", -- Lock on suspend or dpms
  "numlockx on",
  {
    "udiskie",
    "-c",
    filesystem.get_configuration_dir() .. "configuration/udiskie.yml",
  }, -- Automount disks.
  "ibus-daemon --xim -d", -- Run ibus-daemon for language and emoji keyboard support
  { notification_daemon },
  -- "/usr/libexec/deja-dup/deja-dup-monitor", -- Run backups using deja-dup on timer
  -- Add applications that need to be killed between reloads
  -- to avoid multipled instances, inside the awspawn script
  { filesystem.get_configuration_dir() .. "configuration/awspawn" }, -- Spawn "dirty" apps that can linger between sessions
}

do
  --HACK: Don't use io.popen, but this needs to be synchronous.
  --This is fixed in the next release of Xorg, but until then, we've got this to inhibit idle timeouts
  local f = assert(io.popen(("loginctl show-session %s -P Type"):format(os.getenv("XDG_SESSION_ID"))))
  local session_type = f:read("l")
  f:close()
  if session_type == "tty" then
    table.insert(run_on_startup, {
      "systemd-inhibit",
      "--what=idle",
      "--who=AwesomeWM",
      "--why=because idle timeout is broken with startx",
      "--mode=block",
      "sleep",
      "infinity",
    })
  end
end

return run_on_startup