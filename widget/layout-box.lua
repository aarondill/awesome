local awful = require("awful")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local wibox = require("wibox")
local clickable_container = require("widget.material.clickable-container")

-- Create an imagebox widget which will contain an icon indicating which layout we're using.
-- We need one layoutbox per screen.
local LayoutBox = function(s)
	local layoutBox = awful.widget.layoutbox(s)
	layoutBox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))

	local margin_box = wibox.widget({
		layoutBox,
		margins = dpi(5),
		widget = wibox.container.margin,
	})
	return clickable_container(margin_box)
end
return LayoutBox
