local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local TaskList = require("widget.task-list")
local TagList = require("widget.tag-list")
local LayoutBox = require("widget.layout-box")
local dpi = require("beautiful").xresources.apply_dpi

local menu = require("widget.launcher")
local brightness = require("widget.brightness")
local battery = require("widget.battery")
--HACK
if type(battery) == "function" then
	battery = battery({})
end

-- Titus - Horizontal Tray
local systray = wibox.widget.systray()
systray:set_horizontal(true)
systray:set_base_size(20)
systray.forced_height = 20

-- Clock / Calendar 24h format
-- local textclock = wibox.widget.textclock('<span font="Roboto Mono bold 9">%d.%m.%Y\n     %H:%M</span>')
-- Clock / Calendar 12AM/PM fornat
local textclock = wibox.widget.textclock('<span font="Roboto Mono 12">%I:%M %p</span>')
-- textclock.forced_height = 36

-- Add a calendar (credits to kylekewley for the original code)
local month_calendar = awful.widget.calendar_popup.month({
	start_sunday = true,
	week_numbers = true,
})
month_calendar:attach(textclock)

local clock_widget = wibox.container.margin(textclock, dpi(13), dpi(13), dpi(9), dpi(8))

local TopPanel = function(s)
	local panel = wibox({
		ontop = true,
		screen = s,
		height = dpi(32),
		width = s.geometry.width,
		x = s.geometry.x,
		y = s.geometry.y,
		stretch = false,
		bg = beautiful.background.hue_800,
		fg = beautiful.fg_normal,
		struts = {
			top = dpi(32),
		},
	})

	panel:struts({
		top = dpi(32),
	})

	panel:setup({
		layout = wibox.layout.align.horizontal,
		{
			layout = wibox.layout.fixed.horizontal,
			menu(s),
			TagList(s),
		},
		TaskList(s),
		{
			layout = wibox.layout.fixed.horizontal,
			wibox.container.margin(systray, dpi(3), dpi(3), dpi(6), dpi(3)),
			-- Layout box
			LayoutBox(s),
			-- Clock
			clock_widget,
			battery,
			brightness({
				step = 5,
				timeout = 5,
				levels = { 1, 25, 50, 75, 100 },
			}),
		},
	})

	return panel
end

return TopPanel
