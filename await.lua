---Use like javascript's new Promise constructor (await(function(resolve) resolve(1) end))
---@generic A
---@param f fun(resolve: fun(a: A, ...: any))
---@return A, any
local function await(f)
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
return await
