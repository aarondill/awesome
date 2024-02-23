local iscallable = require("util.types.iscallable")
local stream = require("stream")
local tables = require("util.tables")
local function get_cache(cache, key)
  local func, len, outer = key.func, key.len, key.outer
  local s = stream
    .new(cache) --
    :filter(function(props) return props.func == func and props.len == len end)
  -- If no arguments, the first found is always valid
  if len <= 0 then return s:next() end
  return s:filter(function(props)
    for i = 1, len do -- iterate each given argument
      if props.outer[i] ~= outer[i] then
        return false -- not same! can't use this function
      end
    end
    return true -- ALL arguments are the same (Referencial equality!!)
  end):next()
end
local Bind = {}
--- Weak cache for functions, as they can be the same if given the function and args
--- Only the values are weak, so they can be retrieved by iterating the keys
Bind.bind_cache = setmetatable({}, { __mode = "v" })
--- must be seperate, because these functions act differently
Bind.with_args_cache = setmetatable({}, { __mode = "v" })

---Return a function which will call func with the original args and any other arguments passed (javascript's function.bind)
---I've tried typing this, but it's not possible with lua-language-server's implementation.
---@generic Ret, Ret2, Ret3, Ret4
---@param func fun(...: unknown): Ret, Ret2, Ret3, Ret4
---@param ... unknown
---@return fun(...: unknown): Ret, Ret2, Ret3, Ret4
function Bind.bind(func, ...)
  if not iscallable(func) then error("func must be a function", 2) end
  local cache = Bind.bind_cache
  local len = select("#", ...)
  local outer = len > 0 and table.pack(...) or nil -- nil if no arguments are passed

  local key = { func = func, len = len, outer = outer } -- key for the cache table (note, can't be directly used, because it's a new table)
  local c = get_cache(cache, key)
  if c then return c end

  local f = function(...)
    if not outer then return func(...) end -- save processing/memory in storing the above table
    local args = select("#", ...) > 0 and tables.tbl_concat(outer, ...) or outer -- Avoid the copy if possible
    return func(table.unpack(args, 1, args.n))
  end
  cache[key] = f
  return f
end
Bind.with_start_args = Bind.bind -- Alias for symetry with Bind.with_args

---Return a function which will call func with the original args and only those args.
---I've tried typing this, but it's not possible with lua-language-server's implementation.
---@generic Ret, Ret2, Ret3, Ret4
---@param func fun(...: unknown): Ret, Ret2, Ret3, Ret4
---@param ... unknown
---@return fun(): Ret, Ret2, Ret3, Ret4
function Bind.with_args(func, ...)
  if not iscallable(func) then error("func must be a function", 2) end
  local cache = Bind.with_args_cache
  local len = select("#", ...)
  local args = len > 0 and table.pack(...) or nil -- nil if no arguments are passed

  local key = { func = func, len = len, outer = args } -- key for the cache table (note, can't be directly used, because it's a new table)
  local c = get_cache(cache, key)
  if c then return c end

  local f = function()
    if not args then return func() end -- save processing/memory in storing the above table
    return func(table.unpack(args, 1, args.n))
  end
  cache[key] = f
  return f
end

setmetatable(Bind, {
  __call = function(self, ...) return self.bind(...) end,
})
return Bind
