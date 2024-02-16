local assertions = require("util.types.assertions")
local iscallable = require("util.types.iscallable")
local notifs = require("util.notifs")
local pcall_handler = require("util.pcall_handler")

---@generic T :function
---Run func and notify on error
---If a custom error handler is provided, it will be called instead of notifing the user.
---@param func T the function to call
---@param on_error? any if type is function, it will be called with the error as the only parameter. Else, it will be returned in the case of an error.
---@return T safe_cb Note: the return types are now different, but lua_ls can't handle the generics neccisary to describe this.
local function handle_error(func, on_error)
  assertions.iscallable(func, "func")
  -- Recursive, but there's no exit handler, so it will be okay
  local on_err_cb = iscallable(on_error) and handle_error(on_error) or on_error

  return function(...)
    local ok, ret = pcall_handler(pcall(func, ...))
    if ok then
      return table.unpack(ret, 1, ret.n) -- Remove the ok boolean
    end

    local err = ret
    if iscallable(on_err_cb) then return on_err_cb(err) end

    -- only notify if no function is provided
    notifs.critical(tostring(err), { title = "Something went terribly wrong" })
    return on_err_cb
  end
end

return handle_error
