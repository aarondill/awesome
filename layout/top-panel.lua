local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local TaskList = require("widget.task-list")
local TagList = require("widget.tag-list")
local LayoutBox = require("widget.layout-box")
local dpi = require("beautiful").xresources.apply_dpi
local mat_clickable_cont = require("widget.material.clickable-container")
local apps = require("configuration.apps")
local launcher = require("widget.launcher")
local Brightness = require("widget.brightness")
local Battery = require("widget.battery")
local CPU = require("widget.cpu")
local installed = require("util.installed")
local replace_in_widget = require("util.replace_in_widget")

local brightness_widget = mat_clickable_cont(Brightness({
	step = 5,
	timeout = 10,
	levels = { 5, 25, 50, 75, 100 },
}))

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
	})

	panel:struts({
		top = dpi(32),
	})

	-- Empty widget to replace with the battery when it's ready
	local battery_placeholder = wibox.widget.textbox("")
	local cpu_placeholder = wibox.widget.textbox("")
	panel:setup({
		layout = wibox.layout.align.horizontal,
		{
			layout = wibox.layout.fixed.horizontal,
			launcher(s),
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
			battery_placeholder,
			cpu_placeholder,
			brightness_widget,
		},
	})

	-- Setup click click handler if calendar is installed
	installed(apps.default.calendar, function(path_or_nil)
		if path_or_nil then
			local click_clock_widget = mat_clickable_cont(clock_widget)
			click_clock_widget:buttons(gears.table.join(awful.button({}, 1, nil, function()
				-- Hide the calendar on click (won't hide otherwise)
				month_calendar.visible = false
				-- needed to ensure it reapears on next mouse-over
				month_calendar._calendar_clicked_on = false

				awful.spawn(path_or_nil)
			end)))
			replace_in_widget(panel.widget, clock_widget, click_clock_widget)
		end
	end)

	-- Check if battery_manager is available
	installed(apps.default.battery_manager, function(path_or_nil)
		local battery_widget = Battery({
			timeout = 15,
			-- If exit successfully, return stdout, else nil
			spawn_on_click = path_or_nil,
		})
		replace_in_widget(panel.widget, battery_placeholder, battery_widget)
	end)

	-- Check if system_manager is available
	installed(apps.default.system_manager, function(path_or_nil)
		local cpu_widget = mat_clickable_cont(CPU({
			timeout = 15,
			precision = 1,
			spawn_on_click = path_or_nil,
			prefix = "",
			suffix = "%",
		}))
		replace_in_widget(panel.widget, cpu_placeholder, cpu_widget)
	end)

	return panel
end

return TopPanel
