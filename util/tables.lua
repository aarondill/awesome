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
---@param f fun(v: V, k: integer): boolean?
function M.foreach(t, f)
  for i, v in ipairs(t) do
    local res = f(v, i)
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
function M.get(tbl, ...)
  local has, v = M.has_key(tbl, ...)
  return has and v or nil
end

return M
