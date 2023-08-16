local notifs = require("util.notifs")
---@generic T :function
---Run func and notify on error
---@param func T the function to call
---@param on_error? any if type is function, it will be called with the error as the only parameter. Else, it will be returned in the case of an error.
---@return T safe_cb Note: the return types are now different, but lua_ls can't handle the generics neccisary to describe this.
local function handle_error(func, on_error)
  assert(type(func) == "function", "Func must be a function")
  -- Recursive, but there's no exit handler, so it will be okay
  local on_err_cb = type(on_error) == "function" and handle_error(on_error) or on_error

  return function(...)
    local res = table.pack(pcall(func, ...))
    local ok = res[1]
    if ok then
      return table.unpack(res, 2, res.n) -- Remove the ok boolean
    end

    local err = res[2]
    notifs.critical(tostring(err), {
      title = "Something went terribly wrong",
    })
    if type(on_err_cb) == "function" then -- Allow returning nil
      return on_err_cb(err)
    else
      return on_err_cb
    end
  end
end

return handle_error
