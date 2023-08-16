local M = {}
--- return a new array containing the concatenation of all of its
--- parameters. Array parameters have their values shallow-copied
--- to the final array. All parameters are must be tables, or else
-- an error is thrown.
---@param ... unknown[] a set of table to join together
---@return table joined a new table containing the concatenation
function M.join(...)
  local t = {}
  local tn = 0
  for n = 1, select("#", ...) do
    local arg = select(n, ...)
    if type(arg) ~= "table" then
      error(string.format("invalid argument '#%d': expected table, got %s", n, type(arg)), 2)
    end
    for argn = 1, (arg.n or #arg) do
      local v = arg[argn]
      tn = tn + 1
      t[tn] = v
    end
  end
  t.n = tn
  return t
end
---Concat all arguments into a copy of t1, returns a new table.
---@param t1 unknown[]
---@param ... unknown
---@return table joined a new table containing the concatenation
function M.concat(t1, ...)
  local t2 = table.pack(...)
  return M.join(t1, t2)
end

return setmetatable(M, {
  __call = function(_, ...)
    return M.join(...)
  end,
})
