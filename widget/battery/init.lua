-------------------------------------------------
-- Battery Widget for Awesome Window Manager
-- Shows the battery status using the ACPI tool
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/battery-widget

-- @author Pavel Makhov
-- @copyright 2017 Pavel Makhov
-------------------------------------------------

local awful = require("awful")
local naughty = require("naughty")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local clickable_container = require("widget.material.clickable-container")

-- acpi sample outputs
-- Battery 0: Discharging, 75%, 01:51:38 remaining
-- Battery 0: Charging, 53%, 00:57:43 until charged
-- Battery 0: Discharging, 25%, discharging at zero rate - will never fully discharge.

local PATH_TO_ICONS = gears.filesystem.get_configuration_dir() .. "widget/battery/icons/"

-- To use colors from beautiful theme put
-- following lines in rc.lua before require("battery"):
--beautiful.tooltip_fg = beautiful.fg_normal
--beautiful.tooltip_bg = beautiful.bg_normal

local function show_battery_warning()
	naughty.notify({
		icon = PATH_TO_ICONS .. "battery-alert.svg",
		icon_size = dpi(40),
		text = "Huston, we have a problem",
		title = "Battery is dying",
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
---The program to spawn on click of the battery. If nil, the battery will not be clickable.
---@field spawn_on_click string?

---Create a new battery widget
---@param args BatteryWidgetConfig?
---@return table BatteryWidget
function Battery(args)
	args = args or {}

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

	if args.spawn_on_click and args.spawn_on_click ~= "" then
		-- make clickable
		widget_button = clickable_container(widget_button)
		widget_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
			awful.spawn(args.spawn_on_click)
		end)))
	end
	-- Alternative to naughty.notify - tooltip. You can compare both and choose the preferred one
	local battery_popup = awful.tooltip({
		objects = { widget_button },
		mode = "outside",
		align = "left",
		preferred_positions = { "right", "left", "top", "bottom" },
	})

	local last_battery_check = os.time()
	watch("acpi -i", (args.timeout or 15), function(_, stdout)
		local batteryIconName = "battery"

		local battery_info = {}
		local capacities = {}
		for s in stdout:gmatch("[^\r\n]+") do
			local status, charge_str, _ = string.match(s, ".+: ([%a%s]+), (%d?%d?%d)%%,?.*")
			if status ~= nil then
				table.insert(battery_info, { status = status, charge = tonumber(charge_str) })
			else
				local cap_str = string.match(s, ".+:.+last full capacity (%d+)")
				table.insert(capacities, tonumber(cap_str))
			end
		end

		local capacity = 0
		for _, cap in ipairs(capacities) do
			capacity = capacity + cap
		end

		local charge = 0
		local status
		for i, batt in ipairs(battery_info) do
			if batt.charge >= charge then
				status = batt.status -- use most charged battery status
				-- this is arbitrary, and maybe another metric should be used
			end

			charge = charge + batt.charge * capacities[i]
		end
		charge = charge / capacity

		if charge >= 0 and charge < (args.low_power or 15) then
			if
				status ~= "Charging"
				and os.difftime(os.time(), last_battery_check) > (args.low_power_frequency or 300)
			then
				-- if 5 minutes have elapsed since the last warning
				last_battery_check = os.time()

				show_battery_warning()
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
		battery_popup.text = string.gsub(stdout, "\n$", "")
		collectgarbage("collect")
	end, widget)

	return widget_button
end

return Battery
