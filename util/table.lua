local M = {}
---Concat elements of a table with a format
---@generic V :unknown
---@param t V[]
---@param format (string|fun(v: V): string)? the format for each element
---@param separator string? the separator between each formatted element
---@return string
function M.concat(t, format, separator)
  local ret = {}
  format = format or "%s"
  for k, v in ipairs(t) do
    ret[k] = type(format) == "string" and format:format(v) or format(v)
  end
  return table.concat(ret, separator)
end

---Appends b_table onto a_table
---@param a_table table
---@param b_table table
---@return table
function M.table_append(a_table, b_table)
  for _, i in ipairs(b_table) do
    table.insert(a_table, i)
  end
  return a_table
end

---Returns a table containing elements that pass the filter
---@generic K, V
---@param t table<K, V>
---@param func fun(k: K, v: V): boolean?
---@return table
function M.filter(t, func)
  local res = {}
  for i, v in pairs(t) do
    if func(i, v) then table.insert(res, v) end
  end
  return res
end
---It's a foreach function. what more do you want?
---@generic V
---@param t V[]
---Return `false` to stop iterating.
---@param f fun(k: integer, v: V): boolean?
function M.foreach(t, f)
  for i, v in ipairs(t) do
    local res = f(i, v)
    if res == false then break end
  end
end

return M
