local notifs = require("util.notifs")

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

---@generic T :function
---Run func and notify on error
---If a custom error handler is provided, it will be called instead of notifing the user.
---@param func T the function to call
---@param on_error? any if type is function, it will be called with the error as the only parameter. Else, it will be returned in the case of an error.
---@return T safe_cb Note: the return types are now different, but lua_ls can't handle the generics neccisary to describe this.
local function handle_error(func, on_error)
  assert(type(func) == "function", "Func must be a function")
  -- Recursive, but there's no exit handler, so it will be okay
  local on_err_cb = type(on_error) == "function" and handle_error(on_error) or on_error

  return function(...)
    local ok, ret = pcall_handler(pcall(func, ...))
    if ok then
      return table.unpack(ret, 2, ret.n) -- Remove the ok boolean
    end

    local err = ret
    if type(on_err_cb) == "function" then return on_err_cb(err) end

    -- only notify if no function is provided
    notifs.critical(tostring(err), { title = "Something went terribly wrong" })
    return on_err_cb
  end
end

return handle_error
