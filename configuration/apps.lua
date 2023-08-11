local concat_command = require("util.concat_command")
local filesystem = require("gears.filesystem")
local notifs = require("util.notifs")
local spawn = require("util.spawn")

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

---Open a terminal with the given command
---@param cmd? string|string[]
---@param spawn_options SpawnOptions? Options to pass to utils.spawn
local function open_terminal(cmd, spawn_options)
  local do_cmd = cmd and concat_command(concat_command(default.terminal, { "-e" }), cmd) or default.terminal
  spawn(do_cmd, spawn_options)
end

---Open a editor with the given file
---@param file? string|string[]
---@param spawn_options SpawnOptions? Options to pass to utils.spawn
local function open_editor(file, spawn_options)
  local do_cmd = file and concat_command(concat_command(default.editor, { "-e" }), file) or default.editor
  spawn(do_cmd, spawn_options)
end
---Open a browser with the given url
---@param url? string|string[]
---@param new_window? boolean whether to create a new window - default false
---@param spawn_options SpawnOptions? Options to pass to utils.spawn
local function open_browser(url, new_window, spawn_options)
  local new_window_arg = { "--new-window" }
  local do_cmd = default.browser ---@type string|string[]
  if new_window then do_cmd = concat_command(do_cmd, new_window_arg) end
  if url then do_cmd = concat_command(do_cmd, url) end
  spawn(do_cmd, spawn_options)
end
---Open the lock screen
---Note, this doesn't block.
---Don't notify due to failure. This function will handle that.
---@param exit_cb? fun(success: boolean) The function to call on exit. success will be true if the screen closed normally, or false if something went wrong.
local function open_lock(exit_cb)
  local pid = spawn(default.lock, {
    sn_rules = false,
    inherit_stdin = false,
    inherit_stdout = false,
    inherit_stderr = false,
    exit_callback = function(reason, code)
      if code ~= 0 then
        notifs.warn(string.format("Exit reason: %s, Exit code: %d", reason, code), {
          title = "Something went wrong running the lock screen",
        })
      end
      -- Call exit_cb with true if the screen closed normally (exit with code 0)
      if exit_cb then exit_cb(reason == "exit" and code == 0) end
    end,
  })
  if exit_cb and type(pid) == "string" then exit_cb(false) end
end

local notification_daemon = "/usr/lib/notification-daemon-1.0/notification-daemon"
if not filesystem.file_executable(notification_daemon) then
  notification_daemon = "/usr/lib/notification-daemon/notification-daemon"
end

local polkit = "/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1"
if not filesystem.file_executable(polkit) then polkit = "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1" end

-- List of apps to start once on start-up - these will (obviosly) only run if available, but no errors will occur if they aren't.
-- These can be tables or strings. They will *not* be run in a shell, so you must invoke it yourself if you so desire.
-- Using a table is safer because quoting isn't an issue
local run_on_start_up = {
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
    table.insert(run_on_start_up, {
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
local open = {
  terminal = open_terminal,
  editor = open_editor,
  lock = open_lock,
  browser = open_browser,
}

return { default = default, run_on_start_up = run_on_start_up, open = open }
