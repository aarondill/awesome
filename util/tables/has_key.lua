---has_key({a={b=1}}, 'a', 'b') returns true
---Checks if a key path exists in the table.
---
---@param tbl table The table to check for the key in
---@param ... unknown A keypath to check for
---@return boolean
---@return unknown|nil value located at the keypath (to save double iterations)
return function(tbl, ...)
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
