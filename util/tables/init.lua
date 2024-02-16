local M = {}
---Concat elements of a table with a format
---@generic V :unknown
---@param t V[]
---@param format (string|fun(v: V): string)? the format for each element
---@param separator string? the separator between each formatted element
---@return string
function M.concat(t, separator, format)
  if not format then return table.concat(t, separator) end
  if type(format) == "function" then -- call format on each element and join
    return table.concat(M.map_val(t, format), separator)
  end
  local ret = {}
  for k, v in ipairs(t) do
    ret[k] = format:format(v)
  end
  return table.concat(ret, separator)
end

---Returns a table containing elements from the function
---@generic K, V, R
---@param t table<K, V>
---@param func fun(v: V, k: K, t: table<K, V>): R
---@return table<K, R>
function M.map(t, func)
  local res = {}
  for i, v in pairs(t) do
    res[i] = func(v, i, t)
  end
  return res
end
---Just like map(), but the function is called with *only* the values
---@generic K, V, R
---@param t table<K, V>
---@param func fun(v: V): R
---@return table<K, R>
function M.map_val(t, func)
  local res = {}
  for i, v in pairs(t) do
    res[i] = func(v)
  end
  return res
end

---Returns the first element for which the function returns true
---@generic K, V
---@param t table<K, V>
---@param func fun(v: V, k: K, t: table<K, V>): boolean?
---@return V?, K?
function M.find(t, func)
  for i, v in pairs(t) do
    if func(v, i, t) then return v, i end
  end
end

---Returns a table containing elements that pass the filter
---@generic K, V
---@param t table<K, V>
---@param func fun(v: V, k: K, t: table<K, V>): boolean?
---@return table
function M.filter(t, func)
  local res = {}
  for i, v in pairs(t) do
    if func(v, i, t) then table.insert(res, v) end
  end
  return res
end
---It's a foreach function. what more do you want?
---@generic V
---@param t V[]
---Return `false` to stop iterating.
---@param f fun(v: V, k: integer, t: V[]): boolean?
function M.foreach(t, f)
  for i, v in ipairs(t) do
    local res = f(v, i, t)
    if res == false then break end
  end
end

---has_key({a={b=1}}, 'a', 'b') returns true
---Checks if a key path exists in the table.
---
---@param tbl table The table to check for the key in
---@param ... unknown A keypath to check for
---@return boolean
---@return unknown|nil value located at the keypath (to save double iterations)
function M.has_key(tbl, ...)
  local keys = table.pack(...)

  assert(type(tbl) == "table", ("table expected, got %s"):format(type(tbl)))
  assert(keys.n > 0, "No keys provided")
  local count = 0
  local tmp = tbl ---@type unknown
  for _, k in ipairs(keys) do
    if type(tmp) ~= "table" then return false, nil end -- not a table
    local v = tmp[k]
    if v == nil then return false, nil end
    tmp = tmp[k]
    count = count + 1
  end
  -- There's a nil key in the list. Nil keys are not allowed in lua
  if count < keys.n then return false, nil end
  return true, tmp
end

---Gets the value at the keypath. Returns nil if the keypath does not exist
---@param tbl table
---@param ... unknown a keypath to get
---@return unknown|nil
function M.get_key(tbl, ...)
  local has, v = M.has_key(tbl, ...)
  return has and v or nil
end

--- Deep compare values for equality
--- @source /usr/share/nvim/runtime/lua/vim/shared.lua
--- Tables are compared recursively unless they both provide the `eq` metamethod.
--- All other types are compared using the equality `==` operator.
---@param a any First value
---@param b any Second value
---@return boolean `true` if values are equals, else `false`
function M.deep_equal(a, b)
  if a == b then return true end
  if type(a) ~= type(b) then return false end
  if type(a) ~= "table" then return false end
  for k, v in pairs(a) do
    if not M.deep_equal(v, b[k]) then return false end
  end
  for k, _ in pairs(b) do
    if a[k] == nil then return false end
  end
  return true
end

--- return a new array containing the concatenation of all of its
--- parameters. Array parameters have their values shallow-copied
--- to the final array. All parameters are must be tables, or else
-- an error is thrown.
---@param ... unknown[] a set of table to join together
---@return table joined a new table containing the concatenation
function M.tbl_join(...)
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
function M.tbl_concat(t1, ...)
  local t2 = table.pack(...)
  return M.join(t1, t2)
end

return M
