local awful = require("awful")
local icons = require("theme.icons")
local apps = require("configuration.apps")

local tags = {
	{
		icon = icons.chrome,
	},
	{
		icon = icons.code,
	},
	{
		icon = icons.social,
	},
	{
		icon = icons.game,
	},
	{
		icon = icons.folder,
	},
	{
		icon = icons.music,
	},
	{
		icon = icons.lab,
	},
	{
		icon = icons.brightness,
	},
	{
		icon = icons.lock,
	},
}

awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.fair,
	awful.layout.suit.max,
	awful.layout.suit.magnifier,
	awful.layout.suit.floating,
}

awful.screen.connect_for_each_screen(function(s)
	for i, tag in pairs(tags) do
		awful.tag.add(i, {
			icon = tag.icon,
			-- Icon only if icon is defined, else show the text
			icon_only = (tag.icon and true) or false,
			layout = awful.layout.layouts[1] or awful.layout.suit.tile,
			gap_single_client = true,
			gap = 4,
			screen = s,
			selected = i == 1,
		})
	end
end)

awful.tag.attached_connect_signal(nil, "property::layout", function(t)
	local currentLayout = awful.tag.getproperty(t, "layout")
	if currentLayout == awful.layout.suit.max then
		t.gap = 0
	else
		t.gap = 4
	end
end)
