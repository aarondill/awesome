require("module.git-submodule") -- ensure autorandr has already been downloaded
local bind = require("util.bind")
local capi = require("capi")
local dbus = require("util.dbus")
local gfile = require("gears.filesystem")
local gtable = require("gears.table")
local notifs = require("util.notifs")
local path = require("util.path")
local spawn = require("util.spawn")
local suspend_listener = require("util.suspend-listener")
local tables = require("util.tables")
local throttle = require("util.throttle")

local M = {}

local conf_dir = gfile.get_configuration_dir()
local spawn_args = { "autorandr", "--change", "--default", "default" }
local _spawn_autorandr = throttle(bind.with_args(spawn.nosn, spawn_args, { on_failure_callback = notifs.error }), 2)

---Run on resume from suspend
local function suspend_handler(is_before)
  if is_before then return end -- Only run after resume
  return _spawn_autorandr()
end
local function autorandr_failure_handler(err)
  local dir = path.resolve(conf_dir, "deps", "autorandr", "contrib", "autorandr_launcher")
  local make_cmd = ("make -C '%s'"):format(dir)
  local msg = table.concat({
    err,
    ("make sure to build by running `%s`"):format(make_cmd),
  }, "\n")
  return notifs.error(msg, { title = "Failed to spawn autorandr-launcher" })
end
--- There's not much of a reason to keep these, but the bus objects
--- *must* be kept from being garbage collected or else the subscrition is lost.
M._subscription_ids = {
  LidIsClosed = nil,
}

local listener_pid ---@type integer?
capi.awesome.connect_signal("exit", function()
  local sig = capi.awesome.unix_signal.SIGTERM or 15
  return capi.awesome.kill(-listener_pid, sig)
end)

---@param mode string? the mode to load, or nil to auto-detect. Note: this should almost never be used!
function M.spawn_autorandr(mode)
  local extra = mode and { "--load", mode } or { "--change" }
  local args = { "autorandr", "--default", "default", table.unpack(extra) }
  return spawn.nosn(args, { on_failure_callback = notifs.error })
end

---Start autorandr-launcher if not already running
---Note that just because this returned an error doesn't necisarily mean that nothing changed!
---@return SpawnInfo?
---@return string? error
function M.start_listener()
  suspend_listener.register_listener(suspend_handler) -- this will handle duplicate listeners
  -- Use UPower to listen for lid state changes
  M._subscription_ids.LidIsClosed = dbus.properties_changed.subscribe(
    "org.freedesktop.UPower",
    "/org/freedesktop/UPower",
    _spawn_autorandr,
    "LidIsClosed"
  )

  _spawn_autorandr() -- Spawn when starting to ensure correct state (also for startup)

  if listener_pid then
    local is_alive = capi.awesome.kill(listener_pid, 0) --Note: could fail due to privaliges, but that's fine
    if is_alive then -- Don't start a second instance!
      return nil, "autorandr-launcher is already running!"
    end
  end

  local info, err = spawn.nosn({ "autorandr-launcher" }, { on_failure_callback = autorandr_failure_handler })
  if not info then return nil, err end
  listener_pid = info.pid
  return info, nil
end

function M.is_active()
  if not listener_pid then return false end
  if capi.awesome.kill(listener_pid, 0) then return true end
  listener_pid = nil
  return false
end

---Stop a running autorandr-launcher
---Note that just because this returned an error doesn't necisarily mean that nothing changed!
---@return true? success
---@return string? error
function M.stop_listener()
  suspend_listener.unregister_listener(suspend_handler)
  if M._subscription_ids.LidIsClosed then
    dbus.properties_changed.unsubscribe(M._subscription_ids.LidIsClosed)
    M._subscription_ids.LidIsClosed = nil
  end

  if not M.is_active() then return nil, "autorandr-launcher is not running!" end
  local sig = capi.awesome.unix_signal.SIGTERM or 15
  local suc = capi.awesome.kill(listener_pid or -1, sig)
  if not suc then return nil, "failed to stop autorandr-launcher" end
  listener_pid = nil
  return true
end

---Note that if one of the previous invocations failed, this may result in odd behaviour
---@return boolean? success if false or nil, something went wrong
---@return string? error
function M.toggle_listener()
  if M.is_active() then return M.stop_listener() end
  local info, err = M.start_listener()
  return info ~= nil, err
end

M.start_listener() -- Setup this module by starting the listener
return M
