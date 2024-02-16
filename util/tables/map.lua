---Returns a table containing elements from the function
---@generic K, V, R
---@param t table<K, V>
---@param func fun(v: V, k: K, t: table<K, V>): R
---@return table<K, R>
return function(t, func)
  local res = {}
  for i, v in pairs(t) do
    res[i] = func(v, i, t)
  end
  return res
end
