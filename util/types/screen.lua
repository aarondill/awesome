local ascreen = require("awful.screen")
local capi = require("capi")
local M = {}

---@return AwesomeScreenInstance?
function M.primary() return capi.screen.primary end

---@return AwesomeScreenInstance?
function M.focused() return ascreen.focused() end

---@param o AwesomeClientInstance | AwesomeScreenInstance | AwesomeTagInstance | integer | nil The object to find screen on.
---@return AwesomeScreenInstance?
function M.get(o)
  if not o then return nil end -- nil
  if type(o) == "number" then return capi.screen[o] end -- index
  if o.screen then return o.screen end -- client / tag
  if o.index and capi.screen[o.index] == o then -- screen
    return o --[[@as AwesomeScreenInstance]]
  end
  return nil -- IDK
end

return M
