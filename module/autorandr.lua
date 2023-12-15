local dbus = require("util.dbus")

local function spawn_autorandr()
  require("util.notifs").info("RUN SPAWN AUTORANDR!")
end

-- Run on resume from suspend
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

local members = { "DeviceAdded", "DeviceRemoved", "DeviceChanged" }
--- HACK: Use Colord to detect added devices
for _, m in ipairs(members) do
  subids[#subids + 1] = dbus.subscribe_signal.subscribe({
    sender = "org.freedesktop.ColorManager",
    object = "/org/freedesktop/ColorManager",

    interface = "org.freedesktop.ColorManager",
    member = m,
    callback = spawn_autorandr,
  })
end

return subids
