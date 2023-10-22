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

function M.filter(t, func)
  local res = {}
  for i, v in ipairs(t) do
    if func(i, v) then table.insert(res, v) end
  end
  return res
end

return M
