local create_inhibitor = require("util.dbus.create_inhibitor")
local get_dbus_property = require("util.dbus.get_prop")

create_inhibitor("handle-power-key", "To manually handle power key", "block")

--This is fixed in the next release of Xorg, but until then, we've got this to inhibit idle timeouts
local XDG_SESSION_ID = os.getenv("XDG_SESSION_ID") -- If this is not available, we can't reliably determine this (easily) anyways.
if not XDG_SESSION_ID then return end -- We're done here

local object_path = ("/org/freedesktop/login1/session/%s"):format(XDG_SESSION_ID)
-- Get session type
return get_dbus_property(
  "org.freedesktop.login1",
  object_path,
  "org.freedesktop.login1.Session",
  "Type",
  function(res, err)
    if err then return end
    assert(res.type == "(v)")
    assert(res.value[1].type == "s")
    local Type = res.value[1].value
    if Type ~= "tty" then return end -- the bug is fixed.
    return create_inhibitor("idle", "Because idle timeout is broken with startx", "block")
  end
)
