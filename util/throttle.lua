---Returns a throttled version of f
---@param f fun(...: unknown): any
---@param delay integer seconds
---@return fun(...: unknown)
local function throttle(f, delay)
  ---@type integer
  local last_called
  return function(...)
    -- We've already called, and it was too soon
    if last_called and os.difftime(last_called, os.time()) < delay then return end
    last_called = os.time() -- Update on successful call
    f(...)
  end
end

return throttle
