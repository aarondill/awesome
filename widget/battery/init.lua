-- Based initially on:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/battery-widget

local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi

local PATH_TO_ICONS = gears.filesystem.get_configuration_dir() .. "widget/battery/icons/"

-- To use colors from beautiful theme put
-- following lines in rc.lua before require("battery"):
--beautiful.tooltip_fg = beautiful.fg_normal
--beautiful.tooltip_bg = beautiful.bg_normal

local function show_battery_warning()
	naughty.notification({
		icon = PATH_TO_ICONS .. "battery-alert.svg",
		icon_size = dpi(40),
		text = "Huston, we have a problem",
		title = ("Battery is dying (%s%%)"):format(charge or "??"),
		timeout = 5,
		hover_timeout = 0.5,
		position = "bottom_left",
		bg = "#d32f2f",
		fg = "#EEE9EF",
		width = 248,
	})
end

---@class BatteryWidgetConfig
---How often to check the battery status (default: 15).
---@field timeout integer?
---What percentage to alert about low power (default: 15). Set to 0 to disable low power warning.
---@field low_power integer?
---How often (in seconds) to wait between alerts about low power (default: 300).
---@field low_power_frequency integer?
---A hard coded path to the /sys/... battery directory (default: first result of /sys/class/power_supply/BAT*)
---@field battery_path string?

---Create a new battery widget
---@param args BatteryWidgetConfig?
---@return table BatteryWidget
function Battery(args)
	args = args or {}
	local M_battery_path = args.battery_path or nil

	local widget = wibox.widget({
		{
			id = "icon",
			widget = wibox.widget.imagebox,
			resize = true,
			image = PATH_TO_ICONS .. "battery.svg",
		},
		{
			id = "text",
			widget = wibox.widget.textbox,
			text = "100%",
		},
		layout = wibox.layout.fixed.horizontal,
	})

	local widget_button = wibox.container.margin(widget, dpi(14), dpi(14), 4, 4)

	-- Alternative to naughty.notify - tooltip. You can compare both and choose the preferred one
	local battery_popup = awful.tooltip({
		objects = { widget_button },
		mode = "outside",
		align = "left",
		text = "No Battery Found",
		preferred_positions = { "right", "left", "top", "bottom" },
	})

	local function get_bat_info(battery_path, callback_fn)
		local status, capacity
		local function get_capacity(stdout)
			capacity = stdout:match("(%d+)\n")
			callback_fn(capacity, status)
		end
		local function get_status(stdout)
			status = stdout:match("(.+)\n")
			awful.spawn.easy_async({ "cat", battery_path .. "/capacity" }, get_capacity)
		end
		awful.spawn.easy_async({ "cat", battery_path .. "/status" }, get_status)
	end

	local last_battery_check = os.time()
	local function set_bat_cb()
    -- stylua: ignore
		if not M_battery_path then return true end

		---@param capacity string?
		---@param status string?
		get_bat_info(M_battery_path, function(capacity, status)
			local batteryIconName = "battery"
			local charge = tonumber(capacity) or 0

			if status ~= "Charging" and charge >= 0 and charge <= (args.low_power or 15) then
				if os.difftime(os.time(), last_battery_check) >= (args.low_power_frequency or 300) then
					-- if 5 minutes have elapsed since the last warning
					last_battery_check = os.time()

					show_battery_warning(charge)
				end
			end
			if status == "Charging" or status == "Full" then
				batteryIconName = batteryIconName .. "-charging"
			end

			local roundedCharge = math.floor(charge / 10) * 10
			if roundedCharge == 0 then
				batteryIconName = batteryIconName .. "-outline"
			elseif roundedCharge ~= 100 then
				batteryIconName = batteryIconName .. "-" .. roundedCharge
			end

			widget.icon:set_image(PATH_TO_ICONS .. batteryIconName .. ".svg")
			local f_charge = math.floor(charge)
			local non_nan_charge = (f_charge ~= f_charge) and 100 or f_charge
			widget.text:set_text(non_nan_charge .. "%")
			-- Update popup text
			battery_popup.text = status
			collectgarbage("collect")
		end)
		return true
	end

	local timer = gears.timer.new({
		timeout = args.timeout or 15,
		call_now = true,
		autostart = false,
		callback = set_bat_cb,
	})
	if M_battery_path then
		set_bat_cb()
		timer:start()
	else
		awful.spawn.easy_async({
			"find",
			"-L", -- follow links
			"/sys/class/power_supply/",
			"-mindepth",
			"1",
			"-maxdepth",
			"1",
			"-name",
			"BAT*",
			"-type",
			"d",
			"-printf",
			"%p\n",
		}, function(stdout)
			-- The path to the battery
			M_battery_path = stdout:match("([^\n]+)")
			set_bat_cb()
			timer:start()
		end)
	end

	return widget_button
end

return Battery
