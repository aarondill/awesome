-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
-- Widget and layout library
local wibox = require("wibox")

-- Create a widget and update its content using the output of a shell
-- command every 10 seconds:
---@param args table unused
local function batterybar(args)
	local batbar = wibox.widget({
		{ id = "batbar", text = "bat: unknown", widget = wibox.widget.textbox },
		layout = wibox.layout.stack,
		set_battery = function(self, val)
			self.batbar.text = string.format("bat: %s", tostring(val))
		end,
	})
	---@param bat string
	---@param cb fun(cap: string):any
	local function get_capacity(bat, cb)
		awful.spawn.easy_async({ "cat", bat .. "/capacity" }, cb)
	end
	---@param bat string
	---@param cb fun(status: string):any
	local function get_status(bat, cb)
		awful.spawn.easy_async({ "cat", bat .. "/status" }, cb)
	end
	---@param bat string
	local function set_bat_cb(bat)
		return function()
			get_capacity(bat, function(cap)
				get_status(bat, function(status)
					batbar.battery = string.format("%s%% %s", cap:gsub("\n", ""), status:gsub("\n", ""))
				end)
			end)
		end
	end

	awful.spawn.easy_async(
		{ "find", "/sys/class/power_supply/", "-mindepth", "1", "-maxdepth", "1", "-name", "BAT?", "-printf", "%p\n" },
		---@param bateries string
		function(bateries)
			local lines = {}
			for str in string.gmatch(bateries, "([^\n]+)") do
				lines[#lines + 1] = str
			end
			table.sort(lines)
			-- The path to the battery
			local bat = lines[1]
			-- Start the timer!
			gears.timer({
				timeout = 30,
				call_now = true,
				autostart = true,
				callback = set_bat_cb(bat),
			})
		end
	)
	return batbar
end

-- https://github.com/hoelzro/obvious
local has_obv, bat = pcall(require, "obvious.battery")
if has_obv then
	return bat
else
	return batterybar
end
