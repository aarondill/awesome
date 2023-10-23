local gfilesystem = require("gears.filesystem")
local gtimer = require("gears.timer")
local prompt = require("awful.widget.prompt")
local spawn = require("util.spawn")

local function Run_prompt()
  local promptbox
  promptbox = prompt({
    history_path = gfilesystem.get_cache_dir() .. "run_prompt_history",
    prompt = "Run: ",
    exe_callback = function(cmd)
      return spawn.spawn(cmd, {
        on_failure_callback = function(err)
          require("util.notifs").info("exe_callback: " .. tostring(promptbox.widget))
          if promptbox.widget then promptbox.widget:set_text(err) end
          if promptbox.timer and promptbox.timer.again then
            return promptbox.timer:again() -- Restart the timer
          end
        end,
      })
    end,
  })

  promptbox.timer = gtimer({
    timeout = 5,
    callback = function()
      promptbox.widget:set_text("")
      return false -- don't repeat
    end,
  })

  local old_run = promptbox.run
  promptbox.run = function(...)
    if promptbox.timer and promptbox.timer.started then promptbox.timer:stop() end
    return old_run(...)
  end

  promptbox.widget.run = function(_widget, ...)
    return promptbox:run(...)
  end -- Expose this on the returned widget
  return promptbox.widget
end
return Run_prompt
