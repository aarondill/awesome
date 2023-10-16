local capi = require("capi")
local lgi = require("lgi")
local Gio = lgi.require("Gio")
local GLib = lgi.require("GLib")

local cached_locks = setmetatable({}, { __mode = "k" })
capi.awesome.connect_signal("exit", function(_)
  for l in pairs(cached_locks) do
    l:close() -- Stops the block
  end
end)

local function handler(bus, gtask, cb)
  local result, err = bus:send_message_with_reply_finish(bus, gtask)

  if err then return cb(nil, err) end -- Something went wrong in the request.

  if result:get_message_type() == "ERROR" then -- Error message was received
    local _, msg_err = result:to_gerror()
    return cb(nil, msg_err)
  end

  local fd_list = result:get_unix_fd_list()
  local fd_num, fd_err = fd_list:get(0) -- Get the first fd returned (the *only* fd returned)
  if fd_err then return cb(nil, fd_err) end

  -- Now turn this fd into something we can close
  local fd = Gio.UnixInputStream.new(fd_num, true)
  cached_locks[fd] = true
  return cb(fd, nil)
end

---@alias WhatInhibit "shutdown"|"sleep"|"idle"|"handle-power-key"|"handle-suspend-key"|"handle-hibernate-key"|"handle-lid-switch"
---@alias GioUnixInputStream unknown

---See `man systemd-inhibit` for more information
---@param what WhatInhibit|WhatInhibit[] What are you inhibiting?
---@param why string Why is this inhibit needed?
---@param who string? Who is taking this lock? defaults to 'AwesomeWM'
---@param mode? 'block'|'delay' defaults to 'block' (for convenience)
---@param cb? fun(fd?: GioUnixInputStream, err?: userdata)
---You can call fd:close() to release the lock early.
---NOTE: when fd is garbage-collected, the lock will be released.
local function create_inhibitor(what, why, mode, who, cb)
  if type(what) == "table" then what = table.concat(what, ":") end ---Colon seperated
  cb = cb or function() end -- Handle nil cb
  who = who or "AwesomeWM"
  mode = mode or "block"
  assert(type(what == "string"), "What must be a string!") -- Note: tables should be concatted by now.
  assert(type(who == "string"), "Who must be a string!")
  assert(mode == "block" or mode == "delay", ("Invalid mode: %s!"):format(mode))
  assert(type(cb == "function"), "cb must be a function!")

  local bus = Gio.bus_get_sync(Gio.BusType.SYSTEM)
  local name = "org.freedesktop.login1"
  local object = "/org/freedesktop/login1"
  local interface = "org.freedesktop.login1.Manager"
  local message = Gio.DBusMessage.new_method_call(name, object, interface, "Inhibit")
  message:set_body(GLib.Variant("(ssss)", { what, who, why, mode }))
  return bus:send_message_with_reply(message, Gio.DBusSendMessageFlags.NONE, -1, nil, handler, cb)
end

return create_inhibitor
