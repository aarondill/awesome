local dbus = require("util.dbus")
local gfile = require("gears.filesystem")
local notifs = require("util.notifs")
local path = require("util.path.init")
local spawn = require("util.spawn")

local conf_dir = gfile.get_configuration_dir()
-- Debounce it!
local last_time = os.time()
local function spawn_autorandr()
  local time = os.time()
  local time_since_last = os.difftime(time, last_time)
  if time_since_last <= 5 then return end
  last_time = time
  local binpath = path.resolve(conf_dir, "deps", "autorandr", "autorandr.py")
  return spawn.nosn({ binpath, "--change", "--default", "--default" })
end

---Run on resume from suspend
require("module.suspend-listener").register_listener(function(is_before)
  if is_before then return end -- Only run after resume
  return spawn_autorandr()
end)
--- There's not much of a reason to keep these, but the bus objects
--- *must* be kept from being garbage collected or else the subscrition is lost.
local subids = {}

-- Use UPower to listen for lid state changes
subids[#subids + 1] = dbus.properties_changed.subscribe(
  "org.freedesktop.UPower",
  "/org/freedesktop/UPower",
  function(_, changed)
    if changed["LidIsClosed"] == nil then return end
    return spawn_autorandr()
  end
)

local binname = "autorandr-launcher"
local binpath = path.resolve(conf_dir, "deps", "autorandr", "contrib", "autorandr_launcher", binname)
spawn.nosn({ gfile.file_executable(binpath) and binpath or binname }, {
  on_failure_callback = function(err)
    return notifs.error(
      err .. ("\nPlease make sure to build by running `make -C '%s'`"):format(path.dirname(binpath)),
      { "Failed to spawn autorandr-launcher" }
    )
  end,
})

-- local members = { "DeviceAdded", "DeviceRemoved", "DeviceChanged" }
-- --- HACK: Use Colord to detect added devices
-- for _, m in ipairs(members) do
--   subids[#subids + 1] = dbus.subscribe_signal.subscribe({
--     sender = "org.freedesktop.ColorManager",
--     object = "/org/freedesktop/ColorManager",
--
--     interface = "org.freedesktop.ColorManager",
--     member = m,
--     callback = function()
--       notifs.info("running color manager callback")
--       return spawn_autorandr()
--     end,
--   })
-- end

return subids
