local lgi = require("lgi")
local Gio = lgi.require("Gio")
---@alias GDBus unknown

-- Workaround for https://github.com/pavouk/lgi/issues/142
---@param type 'system'|'session'
---@return GDBus bus
local function bus_get_async(type)
  Gio.bus_get(type, nil, coroutine.running())
  local _, b = coroutine.yield()
  return Gio.bus_get_finish(b)
end

return bus_get_async
