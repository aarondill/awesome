local assert_util = require("util.assert_util")
local gtimer = require("gears.timer")

---Returns a debounced version of f
---@param f fun(...: unknown): any
---@param delay integer seconds
---@return fun(...: unknown)
local function debounce(f, delay)
  assert_util.iscallable(f, false, "f", 2)
  assert_util.type(delay, "number", "delay", 2)
  assert_util.assert(delay > 0, "delay must be positive", 2)

  -- We have to use a timer to allow milliseconds (os.time can only support seconds)
  local indirect = { args = {} } -- needed to allow changing the args before the timer ends
  local timer = gtimer.new({
    timeout = delay,
    single_shot = true, -- only run once
    callback = function()
      f(table.unpack(indirect.args, 1, indirect.args.n))
    end,
  })
  return function(...)
    if timer.started then timer:stop() end
    indirect.args = table.pack(...)
    timer:start() -- Restart the counter
  end
end

return debounce
