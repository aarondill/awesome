local array_join = require("util.array_join")
---Return a function which will call func with the original args (javascript's function.bind)
---I've tried typing this, but it's not possible with lua-language-server's implementation.
---@generic Ret
---@param func fun(...: unknown): Ret
---@param ... unknown
---@return fun(...: unknown): Ret
local function bind(func, ...)
  local outer = table.pack(...)
  return function(...)
    -- Avoid the copy if possible
    local args = select("#", ...) > 0 and array_join.concat(outer, ...) or outer
    return func(table.unpack(args, 1, args.n))
  end
end

return bind
