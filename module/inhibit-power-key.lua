---@diagnostic disable-next-line :undefined-global
local capi = { awesome = awesome }
local lgi = require("lgi")
local Gio = lgi.require("Gio")
local GLib = lgi.require("GLib")

-- Workaround for https://github.com/pavouk/lgi/issues/142
local function bus_get_async(type)
  Gio.bus_get(type, nil, coroutine.running())
  local _, b = coroutine.yield()
  return Gio.bus_get_finish(b)
end

local function inhibit(bus, what, who, why, mode)
  local name = "org.freedesktop.login1"
  local object = "/org/freedesktop/login1"
  local interface = "org.freedesktop.login1.Manager"
  local message = Gio.DBusMessage.new_method_call(name, object, interface, "Inhibit")
  message:set_body(GLib.Variant("(ssss)", { what, who, why, mode }))

  local timeout = -1 -- Just use the default
  local result, err = bus:async_send_message_with_reply(message, Gio.DBusSendMessageFlags.NONE, timeout, nil)

  if err then
    print("error: " .. tostring(err))
    return
  end

  if result:get_message_type() == "ERROR" then
    local _, err = result:to_gerror()
    print("error: " .. tostring(err))
    return
  end

  local fd_list = result:get_unix_fd_list()
  local fd, err = fd_list:get(0)
  if err then
    print("error: " .. tostring(err))
    return
  end

  -- Now... somehow turn this fd into something we can close
  return Gio.UnixInputStream.new(fd, true)
end

local main = Gio.Async.call(function()
  local bus = bus_get_async(Gio.BusType.SYSTEM)
  -- The block is lost when this is garbage collected! It is scope leaked into the awesome.connect_signal to avoid this.
  local fd = inhibit(bus, "handle-power-key", "AwesomeWM", "To manually handle power key", "block")
  if not fd then
    return --something went wrong
  end

  capi.awesome.connect_signal("exit", function(_)
    -- Stops the block
    fd:close()
    -- Speed up deletion of the GDBusMessage that still references the FD
    collectgarbage("collect")
    collectgarbage("collect")
  end)
end)

main()
