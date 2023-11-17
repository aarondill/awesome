local gfilesystem = require("gears.filesystem")
local gtimer = require("gears.timer")
local path = require("util.path")
local prompt = require("awful.widget.prompt")
local spawn = require("util.spawn")

local function Run_prompt()
  local promptbox
  promptbox = prompt({
    history_path = path.join(gfilesystem.get_cache_dir(), "run_prompt_history"),
    prompt = "Run: ",
    exe_callback = function(cmd)
      return spawn.spawn(cmd, {
        on_failure_callback = function(err)
          if promptbox.widget then promptbox.widget:set_text(err) end
          if promptbox.timer and promptbox.timer.again then
            return promptbox.timer:again() -- Restart the timer
          end
        end,
      })
    end,
  })

  promptbox.timer = gtimer.new({
    timeout = 5,
    single_shot = true,
    callback = function()
      promptbox.widget:set_text("")
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
  promptbox.widget.promptbox = promptbox -- Allow the returned widget to access the promptbox
  return promptbox.widget
end
return Run_prompt
