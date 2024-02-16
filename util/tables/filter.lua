---Returns a table containing elements that pass the filter
---@generic K, V
---@param t table<K, V>
---@param func fun(v: V, k: K, t: table<K, V>): boolean?
---@return table
return function(t, func)
  local res = {}
  for i, v in pairs(t) do
    if func(v, i, t) then table.insert(res, v) end
  end
  return res
end
