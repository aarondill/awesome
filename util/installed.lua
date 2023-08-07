local awful = require("awful")
local notifs = require("util.notifs")
local handle_error = require("util.handle_error")

-- State to ensure only one notification is sent
local has_notified = false

---Check if a program is available and pass it to the callback.
---Uses 'which' to find the executable. Will only when 'which' itself is installed.
---@param program string? the program to check. If nil, will not be checked.
---@param cb fun(path: string?) run with the path if found, or nil if not found.
---WARNING: Use sparingly, as this function must call 'which' and wait for it's response.
---If possible, cache the results and avoid calling it again.
local function installed(program, cb)
  awful.spawn.easy_async(
    { "which", program },
    handle_error(function(stdout, _, exitreason, exitcode)
      -- If command not found
      if exitreason == "exit" and exitcode == 127 then
        if not has_notified then
          notifs.warn("Please ensure 'which' is installed to have a better experience.", {
            title = "Could not find 'which'",
          })
        end
      end

      if exitreason == "exit" and exitcode == 0 then
        cb(stdout)
      else
        cb(nil)
      end
    end)
  )
end

return installed
