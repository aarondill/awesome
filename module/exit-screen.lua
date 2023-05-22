local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local icons = require("theme.icons")
local clickable_container = require("widget.material.clickable-container")
local apps = require("configuration.apps")
local dpi = require("beautiful").xresources.apply_dpi

-- Appearance
local icon_size = beautiful.exit_screen_icon_size or dpi(140)

--TODO: add the text
local function buildButton(icon, text)
	local abutton = wibox.widget({
		wibox.widget({
			wibox.widget({
				wibox.widget({
					image = icon,
					widget = wibox.widget.imagebox,
				}),
				top = dpi(16),
				bottom = dpi(16),
				left = dpi(16),
				right = dpi(16),
				widget = wibox.container.margin,
			}),
			shape = gears.shape.circle,
			forced_width = icon_size,
			forced_height = icon_size,
			widget = clickable_container,
		}),
		left = dpi(24),
		right = dpi(24),
		widget = wibox.container.margin,
	})

	return abutton
end

-- Get screen geometry
local screen_geometry = awful.screen.focused().geometry

-- Create the widget
local exit_screen = wibox({
	screen = 1,
	x = screen_geometry.x,
	y = screen_geometry.y,
	visible = false,
	ontop = true,
	type = "splash",
	height = screen_geometry.height,
	width = screen_geometry.width,
})

exit_screen.bg = beautiful.background.hue_800 .. "dd"
exit_screen.fg = beautiful.exit_screen_fg or beautiful.wibar_fg or "#FEFEFE"

local exit_screen_grabber

local function exit_screen_hide()
	awful.keygrabber.stop(exit_screen_grabber)
	exit_screen.visible = false
end

local function suspend_command()
	exit_screen_hide()
	awful.spawn(apps.default.lock, false) -- This doesn't block
	awful.spawn({ "systemctl", "suspend" }, false)
end
local function exit_command()
	awesome.quit()
end
local function lock_command()
	exit_screen_hide()
	awful.spawn({ "sh", "-c", "sleep 1 && exec" .. apps.default.lock }, false)
end
local function poweroff_command()
	awful.spawn("poweroff", false)
	awful.keygrabber.stop(exit_screen_grabber)
end
local function reboot_command()
	awful.spawn("reboot", false)
	awful.keygrabber.stop(exit_screen_grabber)
end

local poweroff = buildButton(icons.power, "Shutdown")
poweroff:connect_signal("button::release", poweroff_command)

local reboot = buildButton(icons.restart, "Restart")
reboot:connect_signal("button::release", reboot_command)

local suspend = buildButton(icons.sleep, "Sleep")
suspend:connect_signal("button::release", suspend_command)

local exit = buildButton(icons.logout, "Logout")
exit:connect_signal("button::release", exit_command)

local lock = buildButton(icons.lock, "Lock")
lock:connect_signal("button::release", lock_command)

function _G.exit_screen_show()
	exit_screen_grabber = awful.keygrabber.run(function(_, key, event)
		if event == "release" then
			return
		end

		if key == "s" then
			suspend_command()
		elseif key == "e" then
			exit_command()
		elseif key == "l" then
			lock_command()
		elseif key == "p" then
			poweroff_command()
		elseif key == "r" then
			reboot_command()
		elseif key == "Escape" or key == "q" or key == "x" then
			exit_screen_hide()
		end
	end)
	exit_screen.visible = true
end

exit_screen:buttons(gears.table.join(
	-- Middle click - Hide exit_screen
	awful.button({}, 2, function()
		exit_screen_hide()
	end),
	-- Right click - Hide exit_screen
	awful.button({}, 3, function()
		exit_screen_hide()
	end)
))
-- Item placement
exit_screen:setup({
	nil,
	{
		nil,
		{
			poweroff,
			reboot,
			suspend,
			exit,
			lock,
			layout = wibox.layout.fixed.horizontal,
		},
		nil,
		expand = "none",
		layout = wibox.layout.align.horizontal,
	},
	nil,
	expand = "none",
	layout = wibox.layout.align.vertical,
})
