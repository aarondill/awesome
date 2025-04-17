---Returns a copy of the table with the keys reversed
---@generic T :table
---@param t T
---@return T
return function(t)
  local new = {}
  local len = #t
  for i, v in ipairs(t) do
    new[len - i + 1] = v
  end
  return new
end
