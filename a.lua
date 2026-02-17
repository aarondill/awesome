---@class AsyncModule
local a = {}
---Use like javascript's new Promise constructor (await(function(resolve) resolve(1) end))
---@generic A
---@param f fun(resolve: fun(a: A, ...: any))
---@return A, any
function a.wait(f)
  local co = coroutine.running()
  local ret
  f(function(...)
    if coroutine.status(co) == "running" then
      ret = ret or table.pack(...)
    else
      coroutine.resume(co, ...)
    end
  end)
  if ret then return table.unpack(ret, 1, ret.n) end
  return coroutine.yield()
end

---Use to define an async function. Use with a.wait(function(resolve) resolve(1) end)
---The (optional) callback is the first argument, other arguments are passed to the function
---The callback will be called with the return value(s)
---Using this avoids the pyramid of doom, but screws with type checking
---@generic A, R
---@param f fun(...: A): R,...: any
---@return fun(cb: fun(r: R): any?,...: A )
function a.sync(f)
  return function(...) -- This is needed to avoid resuming a dead coroutine
    local args = table.pack(...)
    return coroutine.wrap(function()
      local callback = args[1]
      -- NOTE: args[1] is the callback, so unpack from 2 to n
      local val = table.pack(f(table.unpack(args, 2, args.n)))
      if callback then return callback(table.unpack(val, 1, val.n)) end
    end)()
  end
end
return a
