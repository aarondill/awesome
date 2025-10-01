local capi = require("capi")
local lgi = require("lgi")
local Gio, GLib = lgi.Gio, lgi.GLib
local GioUnix = lgi.GioUnix
local assertions = require("util.types.assertions")
---@alias create_inhibitor_cb fun(fd?: GioUnixInputStream, err?: userdata)

local cached_locks = setmetatable({}, { __mode = "k" })
local cached_locks_strong = {} -- Used to keep locks without a callback
capi.awesome.connect_signal("exit", function(_)
  for l in pairs(cached_locks_strong) do
    l:close() -- Stops the block
  end
  for l in pairs(cached_locks) do
    l:close() -- Stops the block
  end
end)

---If cb is defined, calls it, else if lock is defined, saves it in a table.
---@param cb? create_inhibitor_cb
local function done(cb, ret, err)
  if cb then
    return cb(ret, err)
  elseif ret then
    cached_locks_strong[ret] = true
  end
end

---@param cb? create_inhibitor_cb
local function handler(result, err, cb)
  if err then return done(cb, nil, err) end -- Something went wrong in the request.

  if result:get_message_type() == "ERROR" then -- Error message was received
    local _, msg_err = result:to_gerror()
    return done(cb, nil, msg_err)
  end

  local fd_list = result:get_unix_fd_list()
  local fd_num, fd_err = fd_list:get(0) -- Get the first fd returned (the *only* fd returned)
  if fd_err then return done(cb, nil, fd_err) end

  -- Now turn this fd into something we can close
  local fd = GioUnix.InputStream.new(fd_num, true)
  cached_locks[fd] = true
  return done(cb, fd, nil)
end

---@alias WhatInhibit "shutdown"|"sleep"|"idle"|"handle-power-key"|"handle-suspend-key"|"handle-hibernate-key"|"handle-lid-switch"
---@alias GioUnixInputStream unknown

---See `man systemd-inhibit` for more information
---@param what WhatInhibit|WhatInhibit[] What are you inhibiting?
---@param why string Why is this inhibit needed?
---@param who string? Who is taking this lock? defaults to 'AwesomeWM'
---@param mode? 'block'|'delay' defaults to 'block' (for convenience)
---@param cb? create_inhibitor_cb
---You can call fd:close() to release the lock early.
---NOTE: when fd is garbage-collected, the lock will be released.
---If no cb is passed, the lock will be kept until awesomewm closes.
---If the cb is passed, this is the user's responsibility!!
local function create_inhibitor(what, why, mode, who, cb)
  if type(what) == "table" then what = table.concat(what, ":") end ---Colon seperated
  who = who or "AwesomeWM"
  mode = mode or "block"
  assertions.type(what, "string", "what") -- Note: tables should be concatted by now.
  assertions.type(who, "string", "who")
  assert(mode == "block" or mode == "delay", ("Invalid mode: %s!"):format(mode))
  assertions.iscallable(cb, true, "cb")

  local name = "org.freedesktop.login1"
  local object = "/org/freedesktop/login1"
  local interface = "org.freedesktop.login1.Manager"
  local message = Gio.DBusMessage.new_method_call(name, object, interface, "Inhibit")
  message:set_body(GLib.Variant("(ssss)", { what, who, why, mode }))
  return Gio.bus_get_sync(Gio.BusType.SYSTEM)
    :send_message_with_reply(message, Gio.DBusSendMessageFlags.NONE, -1, nil, function(bus, gtask)
      local result, err = bus:send_message_with_reply_finish(gtask)
      return handler(result, err, cb)
    end)
end

return create_inhibitor
