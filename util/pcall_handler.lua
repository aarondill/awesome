---Handle pcall by packing the return values if ok
---@param ok boolean?
---@param ... unknown
---@return boolean
---@return table|unknown
local function pcall_handler(ok, ...)
  ok = not not ok ---@cast ok boolean
  if ok then -- only return a table if ok
    return ok, table.pack(...)
  end
  return ok, ...
end
return pcall_handler
