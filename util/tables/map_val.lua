---Just like map(), but the function is called with *only* the values
---@generic K, V, R
---@param t table<K, V>
---@param func fun(v: V): R
---@return table<K, R>
return function(t, func)
  local res = {}
  for i, v in pairs(t) do
    res[i] = func(v)
  end
  return res
end
