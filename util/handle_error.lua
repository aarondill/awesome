local notifs = require("util.notifs")
---Run func and notify on error
---Not typed because generics can't handle it properly
local function handle_error(func)
  return function(...)
    local ok, val_or_err = pcall(func, ...)
    if ok then
      return val_or_err
    end

    notifs.critical(tostring(val_or_err), {
      title = "Something went terribly wrong",
    })
    return nil
  end
end

return handle_error
