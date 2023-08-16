local gtable = require("gears.table")
---Return a function which will call func with the original args (javascript's function.bind)
---I've tried typing this, but it's not possible with lua-language-server's implementation.
---@generic Ret
---@param func fun(...: unknown): Ret
---@param ... unknown
---@return fun(...: unknown): Ret
local function bind(func, ...)
  local outer = { ... }
  return function(...)
    -- Avoid the copy if possible
    local args = select("#", ...) > 0 and gtable.join(outer, { ... }) or outer
    return func(table.unpack(args))
  end
end

return bind
