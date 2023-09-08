local array_join = require("util.array_join")
local Bind = {}
---Return a function which will call func with the original args and any other arguments passed (javascript's function.bind)
---I've tried typing this, but it's not possible with lua-language-server's implementation.
---@generic Ret
---@param func fun(...: unknown): Ret
---@param ... unknown
---@return fun(...: unknown): Ret
function Bind.bind(func, ...)
  if type(func) ~= "function" then error("func must be a function", 2) end
  local outer = table.pack(...)
  return function(...)
    -- Avoid the copy if possible
    local args = select("#", ...) > 0 and array_join.concat(outer, ...) or outer
    return func(table.unpack(args, 1, args.n))
  end
end
Bind.with_start_args = Bind.bind -- Alias for symetry with Bind.with_args

---Return a function which will call func with the original args and only those args.
---I've tried typing this, but it's not possible with lua-language-server's implementation.
---@generic Ret
---@param func fun(...: unknown): Ret
---@param ... unknown
---@return fun(): Ret
function Bind.with_args(func, ...)
  if type(func) ~= "function" then error("func must be a function", 2) end
  local args = table.pack(...)
  return function()
    return func(table.unpack(args, 1, args.n))
  end
end

setmetatable(Bind, {
  __call = function(self, ...)
    return self.bind(...)
  end,
})
return Bind
