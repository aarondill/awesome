local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local TaskList = require("widget.task-list")
local TagList = require("widget.tag-list")
local LayoutBox = require("widget.layout-box")
local dpi = require("beautiful").xresources.apply_dpi
local mat_clickable_cont = require("widget.material.clickable-container")
local apps = require("configuration.apps")
local launcher = require("widget.launcher")
local has_brightness, Brightness = pcall(require, "widget.brightness")
local Battery = require("widget.battery")
local CPU = require("widget.cpu")
local Run_prompt = require("widget.run-prompt")
local make_clickable_if_prog = require("util.make_clickable_if_prog")
local naughty = require("naughty")

local brightness_widget = nil
if false then -- HACK: broken in awesome-git
	brightness_widget = mat_clickable_cont(Brightness({
		step = 5,
		timeout = 10,
		levels = { 5, 25, 50, 75, 100 },
	}))
else
	naughty.notification({ message = "Brightness is broken in awesome-git", preset = naughty.config.presets.info })
end

-- Titus - Horizontal Tray
local systray = wibox.widget.systray()
systray:set_horizontal(true)
systray:set_base_size(20)
-- systray.forced_height = 20

-- Clock / Calendar 24h format
-- local textclock = wibox.widget.textclock('<span font="Roboto Mono bold 9">%d.%m.%Y\n     %H:%M</span>')
-- Clock / Calendar 12AM/PM fornat
local textclock = wibox.widget.textclock('<span font="Roboto Mono 12">%I:%M %p</span>')
-- textclock.forced_height = 36

-- Add a calendar (credits to kylekewley for the original code)
local month_calendar = awful.widget.calendar_popup.month({
	start_sunday = true,
	week_numbers = false,
})

local clock_widget = wibox.container.margin(textclock, dpi(13), dpi(13), dpi(9), dpi(8))
month_calendar:attach(clock_widget)

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
	})

	panel:struts({
		top = dpi(32),
	})

	-- Empty widget to replace with the battery when it's ready
	local battery_widget = Battery({ timeout = 15 })
	local cpu_widget = CPU({
		timeout = 15,
		precision = 1,
		prefix = "",
		suffix = "%",
	})
	panel:setup({
		layout = wibox.layout.align.horizontal,
		{
			layout = wibox.layout.fixed.horizontal,
			launcher(s),
			TagList(s),
			Run_prompt(s),
		},
		TaskList(s),
		{
			layout = wibox.layout.fixed.horizontal,
			wibox.container.margin(systray, dpi(3), dpi(3), dpi(6), dpi(3)),
			-- Layout box
			LayoutBox(s),
			-- Clock
			clock_widget,
			battery_widget,
			cpu_widget,
			brightness_widget,
		},
	})
	s:connect_signal("property::geometry", function()
		panel.width = s.geometry.width
		panel.x = s.geometry.x
		panel.y = s.geometry.y
	end)

	-- Setup click click handler if calendar is installed
	make_clickable_if_prog(apps.default.calendar, clock_widget, panel.widget, function(path)
		-- Hide the calendar on click (won't hide otherwise)
		month_calendar.visible = false
		-- needed to ensure it reapears on next mouse-over
		month_calendar._calendar_clicked_on = false
		awful.spawn(path)
	end)

	-- Check if battery_manager is available
	make_clickable_if_prog(apps.default.battery_manager, battery_widget, panel.widget, function(path)
		awful.spawn(path)
	end)

	-- Check if system_manager is available
	make_clickable_if_prog(apps.default.system_manager, cpu_widget, panel.widget, function(path)
		awful.spawn(path)
	end)

	return panel
end

return TopPanel
