local M = {}
---@alias suspendCallback fun(is_before: boolean): any
M.callbacks = {} ---@type table<suspendCallback, unknown>
M.callbacks_weak = setmetatable({}, { __mode = "v" }) ---@type table<suspendCallback, unknown>

---@type GDBusSignalCallback
local function handler(_bus, _sender, _object, _interface, _signal, params)
  -- "signals are sent right before (with the argument True) and
  -- after (with the argument False) the system goes down for
  -- reboot/poweroff, resp. suspend/hibernate."
  local before_sleep = params[1]
  for cb in pairs(M.callbacks) do
    cb(before_sleep)
  end
  for cb in pairs(M.callbacks_weak) do
    cb(before_sleep)
  end
end

local id = nil ---@type SubscribeID?
---Creates a new subscription.
---Safe to call after already created subscription
local function create_subscription()
  if id then return end -- Keep the single subscription
  -- This *needs* to be scope leaked above! The subscription will be lost if the bus is GCed
  id = require("util.dbus.subscribe_signal").subscribe({
    sender = "org.freedesktop.login1",
    interface = "org.freedesktop.login1.Manager",
    object = "/org/freedesktop/login1",
    member = "PrepareForSleep",
    callback = handler,
  })
end
---Removes the subscription to the signal.
---Safe to call even when callbacks still exist.
local function remove_subscription()
  if not id then return end -- There's no subscription.
  if next(M.callbacks) then return end -- there's one+ callbacks still
  require("util.dbus.subscribe_signal").unsubscribe(id)
  id = nil
end

---Register a callback
---@param cb suspendCallback
---@param opts? {weak: unknown} if weak is non-nil, use it as the key in a weak table
---@return boolean success whether something changed.
M.register_listener = function(cb, opts)
  opts = opts or {}
  if opts.weak then
    if M.callbacks_weak[cb] == opts.weak then return false end
    M.callbacks_weak[cb] = opts.weak
  else
    if M.callbacks[cb] then return false end
    M.callbacks[cb] = true
  end
  create_subscription() -- Ensure we are connected to dbus!
  return true
end
---Remove a previously registered callback
---@param cb suspendCallback
---@param opts? {weak: unknown} if weak is non-nil, use it in a weak table
---@return boolean success whether something changed.
M.unregister_listener = function(cb, opts)
  opts = opts or {}
  if opts.weak then
    if M.callbacks_weak[cb] == nil then return false end
    M.callbacks_weak[cb] = nil
  else
    if not M.callbacks[cb] then return false end
    M.callbacks[cb] = nil
  end
  remove_subscription()
  return true
end

return M
