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
      _extra = { "yay", "-S", "--needed", "--" },
      _repo = { "pacman", "-S", "--needed", "--" },
    },
  },

  ---@class PackageInfo
  ---@field description string
  ---@field url? string
  ---@class ExtPackageList
  ---@field _extra? PackageList
  ---@field _repo PackageList
  ---@alias PackageList {[string]: string|PackageInfo} Package name to description (why it's needed)

  ---@type table<string, PackageList|ExtPackageList>
  ---TODO: Add descriptions
  packages = {
    debian = { ---@type PackageList
      ["awesome"] = { description = "AwesomeWM", url = "https://awesomewm.org/" },
      ["fonts-roboto"] = { description = "The primary font", url = "https://fonts.google.com/specimen/Roboto" },
      ["rofi"] = {
        description = "Window switcher and application launcher",
        url = "https://github.com/davatorium/rofi",
      },
      ["picom"] = { description = "Compositor", url = "https://github.com/yshui/picom" },
      ["i3lock"] = { description = "Screen locker - `lock` script", url = "https://i3wm.org/i3lock/" },
      ["xclip"] = { description = "Copy to clipboard", url = "https://github.com/astrand/xclip" },
      ["qt5-style-plugins"] = {
        description = "Use GTK theme in Qt applications",
        url = "https://github.com/qt/qtstyleplugins",
      },
      ["brightnessctl"] = {
        description = "adjusting screen brightness with keyboard shortcuts",
        url = "https://github.com/Hummer12007/brightnessctl",
      },
      ["flameshot"] = { description = "Screenshot tool", url = "https://flameshot.org" },
      ["pasystray"] = { description = "Audio - System Tray", url = "https://github.com/christophgysin/pasystray" },
      ["network-manager-gnome"] = { description = "Network - System Tray", url = "https://apps.gnome.org" },
      ["policykit-1-gnome"] = { description = "Polkit", url = "https://wiki.gnome.org/Projects/PolicyKit" },
      ["blueman"] = { description = "Bluetooth - System Tray", url = "https://github.com/blueman-project/blueman" },
      ["diodon"] = { description = "Persistent cliboard manager", url = "https://github.com/diodon-dev/diodon" },
      ["udiskie"] = {
        description = "Automatically mount removable media - System Tray",
        url = "https://github.com/coldfix/udiskie",
      },
      ["xss-lock"] = {
        description = "Auto-lock on suspend/idle",
        url = "https://bitbucket.org/raymonad/xss-lock/src/master/",
      },
      ["ibus"] = { description = "Changing input method - System Tray", url = "https://github.com/ibus/ibus" },
      ["numlockx"] = { description = "Enable Numlock on startup", url = "https://github.com/rg3/numlockx" },
      ["playerctl"] = { description = "Control media players", url = "https://github.com/altdesktop/playerctl" },
      ["libinput-tools"] = {
        description = "Needed for libinput-gestures (touchpad gestures)",
        url = "https://wayland.freedesktop.org/libinput/doc/latest/",
      },
      ["x11-xserver-utils"] = {
        description = "xrandr - needed for autorandr, xset - disable DPMS",
        url = "https://www.x.org/wiki/",
      },
      ["redshift"] = {
        description = "Automatically adjust screen temperature",
        url = "https://github.com/jonls/redshift",
      },
      ["pulseaudio-utils"] = {
        description = "Adjust volume with keyboard shortcuts",
        url = "https://www.freedesktop.org/wiki/Software/PulseAudio/",
      },
    },
    arch = {
      _extra = { ---@type PackageList
        ["rofi-git"] = {
          description = "Window switcher and application launcher - Git Version has some fixes",
          url = "https://github.com/davatorium/rofi",
        },
        ["qt5-styleplugins"] = {
          description = "Use GTK theme in Qt applications",
          url = "https://github.com/qt/qtstyleplugins",
        },
        ["diodon"] = { description = "Persistent cliboard manager", url = "https://github.com/diodon-dev/diodon" },
      },
      _repo = { ---@type PackageList
        ["awesome"] = { description = "AwesomeWM", url = "https://awesomewm.org/" },
        ["ttf-roboto"] = { description = "The primary font", url = "https://fonts.google.com/specimen/Roboto" },
        ["picom"] = { description = "Compositor", url = "https://github.com/yshui/picom" },
        ["i3lock"] = { description = "Screen locker - `lock` script", url = "https://i3wm.org/i3lock/" },
        ["xclip"] = { description = "Copy to clipboard", url = "https://github.com/astrand/xclip" },
        ["brightnessctl"] = {
          description = "adjusting screen brightness with keyboard shortcuts",
          url = "https://github.com/Hummer12007/brightnessctl",
        },
        ["flameshot"] = { description = "Screenshot tool", url = "https://flameshot.org" },
        ["pasystray"] = { description = "Audio system tray", url = "https://github.com/christophgysin/pasystray" },
        ["network-manager-applet"] = { description = "Network - System Tray", url = "https://apps.gnome.org" },
        ["polkit-gnome"] = { description = "Polkit", url = "https://wiki.gnome.org/Projects/PolicyKit" },
        ["blueman"] = { description = "Bluetooth - System Tray", url = "https://github.com/blueman-project/blueman" },
        ["udiskie"] = {
          description = "Automatically mount removable media - System Tray",
          url = "https://github.com/coldfix/udiskie",
        },
        ["xss-lock"] = {
          description = "Auto-lock on suspend/idle",
          url = "https://bitbucket.org/raymonad/xss-lock/src/master/",
        },
        ["ibus"] = { description = "Changing input method - System Tray", url = "https://github.com/ibus/ibus" },
        ["numlockx"] = { description = "Enable Numlock on startup", url = "https://github.com/rg3/numlockx" },
        ["playerctl"] = { description = "Control media players", url = "https://github.com/altdesktop/playerctl" },
        ["libinput"] = {
          description = "Needed for libinput-gestures (touchpad gestures)",
          url = "https://wayland.freedesktop.org/libinput/doc/latest/",
        },
        ["xorg-xrandr"] = {
          description = "xrandr - needed for autorandr, xset - disable DPMS",
          url = "https://www.x.org/wiki/",
        },
        ["redshift"] = {
          description = "Automatically adjust screen temperature",
          url = "https://github.com/jonls/redshift",
        },
        ["libpulse"] = {
          description = "Adjust volume with keyboard shortcuts",
          url = "https://www.freedesktop.org/wiki/Software/PulseAudio/",
        },
        ["pacutils"] = { description = "Get update count", url = "https://github.com/andrewgregory/pacutils" },
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
  while M.aliases[id] do
    id = M.aliases[id]
  end
  assert(M.commands[id], ("Unsupported OS: %s. Use --no-install to skip installing packages"):format(id))
  if id == "arch" then --- Use the ./PKGBUILD to install packages (so they are dependencies)
    local tmpdir = Gio.File.new_for_path("./tmpdir." .. (os.time() % 1000))
    tmpdir:make_directory_with_parents() -- Create tmpdir
    Gio.File.new_for_path("./PKGBUILD"):copy(tmpdir:get_child("PKGBUILD"), "ALL_METADATA", nil, nil) -- Copy PKGBUILD to tmpdir
    local yay = GLib.find_program_in_path("yay")
    local cmd
    if yay then
      cmd = { "yay", "-Bi", "--needed", "--", tmpdir:get_path() }
    else
      cmd = { "makepkg", "-sirc", "--dir", tmpdir:get_path() }
      log.warn("yay not found, falling back to makepkg. AUR packages will not be installed!")
    end
    local ok, err = pcall(utils.spawn_check, "install packages", cmd, { cwd = tmpdir })
    do
      local ok, err = pcall(utils.spawn_check, "cleanup", { "rm", "-rf", tmpdir:get_path() })
      if not ok then log.warn("Failed to remove tmpdir: " .. tostring(err)) end
    end
    assert(ok, err)
  else
    local cmd = assert(_get_install_cmd(id), "BUG: Failed to construct command")
    utils.spawn_check("install packages", cmd)
  end
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

  local XOOP_DIR = dir:get_child("./deps/xoop")
  utils.spawn_check(
    ("compile Xoop (%s)"):format(dir:get_relative_path(XOOP_DIR)),
    { "make", "-s" },
    { cwd = assert(XOOP_DIR:get_path()) }
  )

  print("Setup completed successfully!")
end

if debug.getinfo(4) == nil then
  M.main() -- If called directly from the command line, run main
end

return M
