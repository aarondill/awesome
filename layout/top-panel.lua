local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local vars = require("variables")
local menu = require("layout.menu")
local TaskList = require("widget.task-list")

local systray = wibox.widget.systray()
systray:set_horizontal(true)
systray:set_base_size(20)
systray.forced_height = 20

-- Load brightness widget
local brightness_widget = wibox.container.constraint(
	require("widget.brightness-wip")({
		step = 5,
		timeout = 10,
		levels = { 1, 25, 50, 75, 100 },
	}),
	"max",
	30
)

local battery_widget = require("widget.battery")({})

-- Keyboard map indicator and switcher
local mykeyboardlayout = awful.widget.keyboardlayout()

-- Create a textclock widget
local textclock = wibox.widget.textclock("%I:%M %p")
-- local mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ vars.modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ vars.modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

-- Create an imagebox widget which will contain an icon indicating which layout we're using.
-- We need one layoutbox per screen.
local LayoutBox = function(s)
	local layoutbox = awful.widget.layoutbox(s)
	layoutbox:buttons(gears.table.join(
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
	return layoutbox
end

local function TopPanel(s)
	-- Each screen has its own tag table.
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	local promptbox = awful.widget.prompt()
	-- HACK: assign to the screen
	s.promptbox = promptbox
	-- Create a taglist widget
	local taglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
	})

	-- Create the wibox
	local panel = awful.wibar({ position = "top", screen = s })
	-- Add widgets to the wibox
	panel:setup({
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			menu.mylauncher,
			taglist,
			promptbox,
		},
		TaskList(s), -- Middle widget
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			mykeyboardlayout,
			systray,
			textclock,
			LayoutBox(s),
			battery_widget,
			brightness_widget,
		},
	})
	return panel
end
return TopPanel
