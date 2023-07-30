local awful = require("awful")
local top_panel = require("layout.top-panel")

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s)
	-- Create the Top bar
	s.top_panel = top_panel(s)
end)

--- Hide bars when app go fullscreen
--- Don't use the parameter without extensive checking
---@param _ table? tag or client
local function updateBarsVisibility(_)
	for s in screen do
		if s.selected_tag then
			local fullscreen = s.selected_tag.fullscreenMode
				or (awful.layout.get(s) == awful.layout.suit.max.fullscreen)

			-- Order matter here for shadow
			s.top_panel.visible = not fullscreen
		end
	end
end

awful.tag.attached_connect_signal(nil, "property::selected", updateBarsVisibility)
awful.tag.attached_connect_signal(nil, "property::layout", updateBarsVisibility)

client.connect_signal("property::fullscreen", function(c)
	c.screen.selected_tag.fullscreenMode = c.fullscreen
	updateBarsVisibility()
end)

local unmanage_signal = awesome.version <= "v4.3" and "unmanage" or "request::unmanage"
client.connect_signal(unmanage_signal, function(c)
	if c.fullscreen then
		c.screen.selected_tag.fullscreenMode = false
		updateBarsVisibility()
	end
end)
