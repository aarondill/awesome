local awful = require("awful")
local gears = require("gears")
local tags = require("configuration.tags")
local layouts = require("configuration.layouts")

awful.screen.connect_for_each_screen(function(s)
	for i, tag in pairs(tags) do
		if not tag then
			goto continue
		end
		if type(tag) ~= "table" then
			if type(tag) == "function" then
				-- Screen, index, array
				tag = tag(s, i, tags)
			elseif type(tag) == "string" or type(tag) == "number" then
				tag = { name = tostring(tag) }
			else
				tag = {}
			end
		end

		local params = gears.table.crush({
			name = i,
			layout = layouts[1] or awful.layout.suit.tile,
			gap_single_client = true,
			gap = 4,
			screen = s,
			selected = i == 1,
		}, tag or {})

		-- icon_only not specified, but icon is. Default to only icon.
		if tag.icon_only == nil and tag.icon and not tag.name then
			params.icon_only = true
		end

		awful.tag.add(params.name, params)
		::continue::
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
