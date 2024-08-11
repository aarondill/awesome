#!/usr/bin/env lua
local GLib, Gio ---@type GLib, Gio
--- Wrap this in a function to avoid dependency on lgi when generating docs
local function _init()
  local has_lgi, lgi = pcall(require, "lgi")
  if not has_lgi then
    io.stderr:write("lgi not found, aborting setup\n")
    return
  end
  GLib, Gio = lgi.GLib, lgi.Gio
end

---@class SetupInfo
local M = {
  ---@type table<string, string>
  aliases = {
    ubuntu = "debian",
  },
  ---@type table<string, string[]|{_extra: string[], _repo: string[]}>
  commands = {
    debian = { "apt", "install", "--" },
    arch = {
      --- Used for aur packages
      _extra = { "yay", "-S", "--" },
      _repo = { "pacman", "-S", "--" },
    },
  },

  ---@alias PackageList table<string, string> Package name to description (why it's needed)
  ---@type table<string, PackageList|{_extra: PackageList, _repo: PackageList}>
  ---TODO: Add descriptions
  packages = {
    debian = { ---@type PackageList
      ["awesome"] = "AwesomeWM",
      ["fonts-roboto"] = "The primary font",
      ["rofi"] = "Window switcher and application launcher",
      ["picom"] = "Compositor",
      ["i3lock"] = "Screen locker",
      ["xclip"] = "Copy to clipboard",
      ["qt5-style-plugins"] = "Use GTK theme in Qt applications",
      ["brightnessctl"] = "adjusting screen brightness with keyboard shortcuts",
      ["flameshot"] = "Screenshot tool",
      ["pasystray"] = "Audio - System Tray",
      ["network-manager-gnome"] = "Network - System Tray",
      ["policykit-1-gnome"] = "Polkit",
      ["blueman"] = "Bluetooth - System Tray",
      ["diodon"] = "Persistent cliboard manager",
      ["udiskie"] = "Automatically mount removable media - System Tray",
      ["xss-lock"] = "Auto-lock on suspend/idle",
      ["ibus"] = "Changing input method - System Tray",
      ["numlockx"] = "Enable Numlock on startup",
      ["playerctl"] = "Control media players",
      ["libinput-tools"] = "Needed for libinput-gestures (touchpad gestures)",
      ["x11-xserver-utils"] = "xrandr - needed for autorandr, xset - disable DPMS",
      ["redshift"] = "Automatically adjust screen temperature",
      ["pulseaudio-utils"] = "Adjust volume with keyboard shortcuts",
    },
    arch = {
      _extra = { ---@type PackageList
        ["rofi-git"] = "Window switcher and application launcher - Git Version has some fixes",
        ["qt5-styleplugins"] = "Use GTK theme in Qt applications",
        ["diodon"] = "Persistent cliboard manager",
      },
      _repo = { ---@type PackageList
        ["awesome"] = "AwesomeWM",
        ["ttf-roboto"] = "The primary font",
        ["picom"] = "Compositor",
        ["i3lock"] = "Screen locker",
        ["xclip"] = "Copy to clipboard",
        ["brightnessctl"] = "adjusting screen brightness with keyboard shortcuts",
        ["flameshot"] = "Screenshot tool",
        ["pasystray"] = "Audio system tray",
        ["network-manager-applet"] = "Network - System Tray",
        ["polkit-gnome"] = "Polkit",
        ["blueman"] = "Bluetooth - System Tray",
        ["udiskie"] = "Automatically mount removable media - System Tray",
        ["xss-lock"] = "Auto-lock on suspend/idle",
        ["ibus"] = "Changing input method - System Tray",
        ["numlockx"] = "Enable Numlock on startup",
        ["playerctl"] = "Control media players",
        ["libinput"] = "Needed for libinput-gestures (touchpad gestures)",
        ["xorg-xrandr"] = "xrandr - needed for autorandr, xset - disable DPMS",
        ["redshift"] = "Automatically adjust screen temperatur",
        ["libpulse"] = "Adjust volume with keyboard shortcuts",
        ["pacutils"] = "Get update count",
      },
    },
  },
}

---@class _Log
local log = {}
---@param msg string
---@param format string
---@param output file*
local function _log(msg, format, output)
  local indented = msg:gsub("\n", "\n  ")
  local formatted = (format):format(indented) .. "\n"
  output:write(formatted)
end
---@param msg string
function log.error(msg) return _log(msg, "ERROR: %s", io.stderr) end
---@param msg string
function log.warn(msg) return _log(msg, "WARNING: %s", io.stderr) end
---@type fun(msg: string, exit_code?: number)
function log.abort(msg, exit_code)
  log.error(msg)
  os.exit(exit_code or 1)
end
---@param fmt string
local function printf(fmt, ...) print(string.format(fmt, ...)) end

---Nicer output for assert, no stack trace
---Note: this can't be log.assert, since assert it a special function name to LuaLS
---@generic T
---@param cond T|nil|false
---@param msg unknown?
---@param ... unknown
---@return T
---@return unknown ...
local function assert(cond, msg, ...)
  if not cond then
    log.abort(tostring(msg) or "assertion failed!")
    _G.assert(false, "BUG: unreachable")
  end
  return cond, msg, ...
end

---Concatenates all tables and returns the result
---@generic T : unknown[]
---@param ... T
---@return T
local function table_concat(...)
  local dest = { n = 0 }
  for i = 1, select("#", ...) do
    local t1_len = dest.n or #dest
    local source = select(i, ...) or {} ---@type unknown[]|{n?: number}
    local source_len = source.n or #source
    table.move(source, 1, source_len, t1_len + 1, dest)
    if dest.n then -- if a length is already set, then we need to update it
      dest.n = dest.n + source_len
    end
  end
  return dest
end
---@generic K
---@param t table<K, unknown>
---@return K[]
local function table_keys(t)
  local keys = {}
  for k in pairs(t) do
    table.insert(keys, k)
  end
  return keys
end

---@param cmd string[]
---@param opts? {cwd?: string}
---@return GSubprocess
local function spawn(cmd, opts)
  opts = opts or {}
  local launcher = Gio.SubprocessLauncher.new(Gio.SubprocessFlags.NONE)
  if opts.cwd then launcher:set_cwd(opts.cwd) end
  return assert(launcher:spawnv(cmd))
end

---Stringifies a table of commands/args.
---Quotes each one and seperates them with delim
---@param args string[] | string A string is treated as a single argument
---@param delim? string default ' '
---@return string escaped
local function shell_escape(args, delim)
  if type(args) == "string" then args = { args } end
  local output = {}
  table.move(args, 1, #args, #output + 1, output)
  for i, arg in ipairs(args) do
    if arg:match("[^A-Za-z0-9_/:-]") then -- If contains special chars
      local escaped = arg:gsub("'", "'\\''")
      output[i] = table.concat({ "'", escaped, "'" }, "")
    end
  end
  return table.concat(output, delim or " ")
end

---@param action string
---@param cmd string[]
---@param opts? {cwd?: string}
local function spawn_check(action, cmd, opts)
  printf("Running %s...", action)
  printf("> %s", shell_escape(cmd))
  local proc = spawn(cmd, opts)
  local ok, err = proc:wait_check()
  assert(ok, ("Command failed: %s"):format(action, err))
end

local function _get_install_cmd(id)
  local commands = assert(M.commands[id], ("BUG: Missing commands for OS: "):format(id))
  local packages = assert(M.packages[id], ("BUG: Missing packages for OS: "):format(id))
  -- Simple table
  if not commands._repo then return table_concat(commands, table_keys(packages)) end

  -- Has repo commands, e.g. Arch pacman
  if not commands._extra then
    local repo_packages = packages._repo
    assert(type(repo_packages) == "table", "BUG: repo packages are not a table!")
    return table_concat(commands._repo, table_keys(repo_packages))
  end

  -- Has extra commands, e.g. Arch AUR. Extra command is expected to be able to install repo packages
  local repo_packages, extra_packages = packages._repo, packages._extra
  assert(type(repo_packages) == "table", "BUG: repo packages are not a table!")
  assert(type(extra_packages) == "table", "BUG: extra packages are not a table!")
  repo_packages, extra_packages = table_keys(repo_packages), table_keys(extra_packages)

  local repo_command, extra_command = commands._repo, commands._extra

  --- If extra command is found in PATH, use it
  if GLib.find_program_in_path(extra_command[1]) then
    return table_concat(extra_command, extra_packages, repo_packages)
  end

  -- Fallback to repo command
  log.warn(("%s not found in PATH, falling back to %s"):format(extra_command[1], repo_command[1]))
  return table_concat(repo_command, repo_packages)
end
---@param id string ID of the OS
function M.install_packages(id)
  assert(M.commands[id], ("Unsupported OS: %s. Use --no-install to skip installing packages"):format(id))
  local cmd = assert(_get_install_cmd(id), "BUG: Failed to construct command")
  spawn_check("install packages", cmd)
end

function M.main()
  _init()
  local script_dir = debug.getinfo(1).source:match("@?(.*/)") or "."
  local dir = Gio.File.new_for_path(script_dir)
  if not dir:query_exists() then log.abort("Current directory does not exist") end
  if GLib.chdir(assert(dir:get_path())) ~= 0 then log.abort("Failed to change directory") end
  do --- Install packages
    local id = assert(GLib.get_os_info("ID_LIKE") or GLib.get_os_info("ID"), "Could not determine OS ID")
    if arg[1] ~= "--no-install" then M.install_packages(id) end
  end

  spawn_check("update submodules", { "git", "submodule", "update", "--init", "--recursive" })

  local AR_LAUNCHER_DIR = dir:get_child("./deps/autorandr/contrib/autorandr_launcher")
  spawn_check(
    ("compile autorandr_launcher (%s)"):format(dir:get_relative_path(AR_LAUNCHER_DIR)),
    { "make", "-s" },
    { cwd = assert(AR_LAUNCHER_DIR:get_path()) }
  )

  print("Setup completed successfully!")
end

if debug.getinfo(4) == nil then
  M.main() -- If called directly from the command line, run main
end

return M
