local awful = require("awful")
local gears = require("gears")
-- local wibox = require("wibox")
-- local dpi = require("beautiful").xresources.apply_dpi
-- local clickable_container = require("widget.material.clickable-container")

local function Run_prompt(s)
	local promptbox = awful.widget.prompt({
		history_path = gears.filesystem.get_cache_dir() .. "run_prompt_history",
		prompt = "Run: ",
	})
	promptbox.exe_callback = function(cmd)
		local result = awesome.spawn(cmd, false)
		if type(result) == "string" then
			promptbox.widget:set_text(result)
		end
	end
	s.run_promptbox = promptbox -- HACK: Attaches to screen object. I don't know how else to do this.
	return promptbox
end
return Run_prompt
