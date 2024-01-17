local assert_util = require("util.assert_util")
local gtimer = require("gears.timer")
---Returns a throttled version of f
---@param f fun(...: unknown): any
---@param delay integer seconds
---@return fun(...: unknown)
local function throttle(f, delay)
  assert_util.iscallable(f, false, "f", 2)
  assert_util.type(delay, "number", "delay", 2)
  assert_util.assert(delay > 0, "delay must be positive", 2)

  -- We have to use a timer to allow milliseconds (os.time can only support seconds)
  local timer = gtimer.new({
    timeout = delay,
    single_shot = true, -- only run once
  })
  return function(...)
    --- timer.started will be false if it's ended (because single_shot)
    if timer.started then return end
    timer:again()
    f(...)
  end
end

return throttle
