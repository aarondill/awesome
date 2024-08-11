#!/usr/bin/env lua
local utils = require("scripts.utils")
local assert, log = utils.assert, utils.log

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

local function _get_install_cmd(id)
  local commands = assert(M.commands[id], ("BUG: Missing commands for OS: "):format(id))
  local packages = assert(M.packages[id], ("BUG: Missing packages for OS: "):format(id))
  -- Simple table
  if not commands._repo then return utils.table_concat(commands, utils.table_keys(packages)) end

  -- Has repo commands, e.g. Arch pacman
  if not commands._extra then
    local repo_packages = packages._repo
    assert(type(repo_packages) == "table", "BUG: repo packages are not a table!")
    return utils.table_concat(commands._repo, utils.table_keys(repo_packages))
  end

  -- Has extra commands, e.g. Arch AUR. Extra command is expected to be able to install repo packages
  local repo_packages, extra_packages = packages._repo, packages._extra
  assert(type(repo_packages) == "table", "BUG: repo packages are not a table!")
  assert(type(extra_packages) == "table", "BUG: extra packages are not a table!")
  repo_packages, extra_packages = utils.table_keys(repo_packages), utils.table_keys(extra_packages)

  local repo_command, extra_command = commands._repo, commands._extra

  --- If extra command is found in PATH, use it
  if GLib.find_program_in_path(extra_command[1]) then
    return utils.table_concat(extra_command, extra_packages, repo_packages)
  end

  -- Fallback to repo command
  log.warn(("%s not found in PATH, falling back to %s"):format(extra_command[1], repo_command[1]))
  return utils.table_concat(repo_command, repo_packages)
end
---@param id string ID of the OS
function M.install_packages(id)
  assert(M.commands[id], ("Unsupported OS: %s. Use --no-install to skip installing packages"):format(id))
  local cmd = assert(_get_install_cmd(id), "BUG: Failed to construct command")
  utils.spawn_check("install packages", cmd)
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

  utils.spawn_check("update submodules", { "git", "submodule", "update", "--init", "--recursive" })

  local AR_LAUNCHER_DIR = dir:get_child("./deps/autorandr/contrib/autorandr_launcher")
  utils.spawn_check(
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
