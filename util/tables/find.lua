---Returns the first element for which the function returns true
---@generic K, V
---@param t table<K, V>
---@param func fun(v: V, k: K, t: table<K, V>): boolean?
---@return V?, K?
return function(t, func)
  for i, v in pairs(t) do
    if func(v, i, t) then return v, i end
  end
end
