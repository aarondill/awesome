local gfile = require("gears.filesystem")
local gstring = require("gears.string")
local gtable = require("gears.table")
local handle_error = require("util.handle_error")
local lgi = require("lgi")
local notifs = require("util.notifs")
local path = require("util.path")
local read_async = require("util.file.read_async")
local shell_escape = require("util.command.shell_escape")
local spawn = require("util.spawn")
local stream = require("stream")
local GLib, Gio = lgi.GLib, lgi.Gio

---@type table<string, boolean>
---A hack to avoid setting the same env vars twice (thus overwriting my own manual settings)
local already_set = {}

---@param env string
---@param val (string|false)? Note: if false or nil is passed, unsets
---@param overwrite boolean? default to true
---@return boolean changed
local function setenv(env, val, overwrite)
  if overwrite ~= false then
    if already_set[env] then return false end
    already_set[env] = true
  end
  if overwrite == nil then overwrite = true end
  if val then return GLib.setenv(env, val, overwrite) end
  if not os.getenv(env) then return false end
  GLib.unsetenv(env)
  return true
end

---@param env table<string, (string|false)?> remember that `nil` keys aren't accessable!
---@param overwrite boolean? default to true
---@return boolean changed
local function setenv_tbl(env, overwrite)
  local changed = false
  for k, v in pairs(env) do
    if setenv(k, v, overwrite) then changed = true end
  end
  return changed
end

---@param progs string[]
---@return string?, string?
local function first_in_path(progs)
  for _, p in ipairs(progs) do
    local ppath = GLib.find_program_in_path(p)
    if ppath then return p, ppath end
  end
end

local function setup_environment()
  local deps_bindir = path.resolve(gfile.get_configuration_dir(), "deps", ".bin")
  -- A default PATH. If $PATH is unset, there's bigger problems.
  local pathvar = os.getenv("PATH") or table.concat({ "/usr/bin", "/bin", "/usr/sbin", "/sbin" }, path.delimiter)
  pathvar = table.concat({ deps_bindir, pathvar }, path.delimiter)

  local ibus = first_in_path({ "ibus", "fcitx" }) -- IBUS --

  return setenv_tbl({
    GTK_IM_MODULE = ibus, -- Fix for browsers
    QT_IM_MODULE = ibus, -- Not sure if this works or not, but whatever
    XMODIFIERS = ibus and ("@im=" .. ibus),
    PATH = pathvar, -- Set the PATH environment variable to include /deps/.bin/
    GTK_THEME = "Yaru:dark", -- Prefer dark theme
    XDG_CURRENT_DESKTOP = "GNOME:AWESOME",
    QT_QPA_PLATFORMTHEME = "gtk2",
    QT_STYLE_OVERRIDE = "gtk2",
    SHLVL = false, -- Fix terminals opened in AwesomeWM
    NO_AT_BRIDGE = "1", -- Don't try to connect to an accessibility bus
    _JAVA_AWT_WM_NONREPARENTING = "1", -- expose awesome as a non-reparenting window to java
    ZEITGEIST_LOG_DIRECT_READ = "1", -- Fix a bug in diodon
  })
end

local function diff_environment(cb)
  ---If we just came from a terminal, don't do anything
  ---This also covers restarts, since we will have unset this variable
  ---NOTE: This has to run before setup_environment, otherwise the environment variables won't be set
  if os.getenv("SHLVL") then return end
  --- Get environment from a shell
  local tmpfile = Gio.File.new_tmp()
  local function cleanup()
    if tmpfile then tmpfile:delete_async(GLib.PRIORITY_DEFAULT) end
    tmpfile = nil
  end

  assert(tmpfile, "Failed to create tmpfile")
  local cat = lgi.GLib.find_program_in_path("cat")
  assert(cat, "cat not found")
  --- Source the profile, then read exported environment variables from /proc/self/environ. Note: `cat` is a subprocess, this is important so that the environment variables are present.
  local cmd = ". ~/.profile && "
    .. shell_escape({ cat, "/proc/self/environ" })
    .. " >| "
    .. shell_escape(assert(tmpfile:get_path()))
  _ = spawn.async_success({ "sh", "-ic", cmd }, function()
    return read_async(tmpfile, function(content, err)
      cleanup()
      assert(not err, "Failed to read env file")
      local env = {} ---@type table<string, string>
      for def in content:gmatch("([^\0]+)\0") do
        local k, v = def:match("^([^=]+)=(.*)$")
        --- These are just extra noise, they won't be used anyway
        --- If it's the same, don't do anything
        if not gstring.startswith(k, "BASH_FUNC_") and os.getenv(k) ~= v then env[k] = v end
      end
      do ---Technically not needed, but nicer output
        for k, _ in pairs(env) do
          if already_set[k] then env[k] = nil end
        end
        if next(env) == nil then return end -- No changes
        local keys = gtable.keys(env)
        local output = table.concat(gtable.map(function(k) return k .. "=" .. env[k] end, keys), "\n")
        notifs.normal(output, { title = "Updated environment from shell" })
      end
      return setenv_tbl(env)
    end)
  end, { on_failure_callback = cleanup }) or cleanup()
end

return handle_error(function()
  diff_environment()
  setup_environment()
end)
