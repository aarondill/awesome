local awful = require("awful")
local gears = require("gears")
local spawn = require("util.spawn")

local timer = gears.timer or timer

local function Run_prompt(s)
  local promptbox = awful.widget.prompt({
    history_path = gears.filesystem.get_cache_dir() .. "run_prompt_history",
    prompt = "Run: ",
  })

  promptbox.timer = timer({
    timeout = 5,
    callback = function()
      promptbox.widget:set_text("")
      return false
    end,
  })

  local old_run = promptbox.run
  promptbox.run = function(...)
    if promptbox.timer and promptbox.timer.started then
      promptbox.timer:stop()
    end
    old_run(...)
  end
  promptbox.exe_callback = function(cmd)
    local result = spawn(cmd, { sn_rules = false })
    if type(result) == "string" then
      promptbox.widget:set_text(result)

      if promptbox.timer and promptbox.timer.again then
        promptbox.timer:again()
      end
    end
  end
  s.run_promptbox = promptbox -- HACK: Attaches to screen object. I don't know how else to do this.
  return promptbox
end
return Run_prompt
