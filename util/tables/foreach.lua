---It's a foreach function. what more do you want?
---@generic V
---@param t V[]
---Return `false` to stop iterating.
---@param f fun(v: V, k: integer, t: V[]): boolean?
return function(t, f)
  for i, v in ipairs(t) do
    local res = f(v, i, t)
    if res == false then break end
  end
end
