local gfilesystem = require("gears.filesystem")
local gtimer = require("gears.timer")
local prompt = require("awful.widget.prompt")
local spawn = require("util.spawn")

local function Run_prompt(s)
  local promptbox = prompt({
    history_path = gfilesystem.get_cache_dir() .. "run_prompt_history",
    prompt = "Run: ",
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
  promptbox.exe_callback = function(cmd)
    spawn.spawn(cmd, {
      on_failure_callback = function(err)
        promptbox.widget:set_text(err)
        if promptbox.timer and promptbox.timer.again then
          return promptbox.timer:again() -- Restart the timer
        end
      end,
    })
  end
  s.run_promptbox = promptbox -- HACK: Attaches to screen object. I don't know how else to do this.
  return promptbox
end
return Run_prompt
