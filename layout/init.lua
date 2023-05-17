local awful = require("awful")
local top_panel = require("layout.top-panel")

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s)
	-- Create the Top bar
	s.top_panel = top_panel(s)
end)

-- Hide bars when app go fullscreen
local function updateBarsVisibility()
	for s in screen do
		if s.selected_tag then
			local fullscreen = s.selected_tag.fullscreenMode
			-- Order matter here for shadow
			s.top_panel.visible = not fullscreen
		end
	end
end

tag.connect_signal("property::selected", updateBarsVisibility)

client.connect_signal("property::fullscreen", function(c)
	c.screen.selected_tag.fullscreenMode = c.fullscreen
	updateBarsVisibility()
end)

client.connect_signal("unmanage", function(c)
	if c.fullscreen then
		c.screen.selected_tag.fullscreenMode = false
		updateBarsVisibility()
	end
end)
