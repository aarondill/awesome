-- Based initially on:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/battery-widget
-- Time remaining (when not charging):
-- echo "$(cat /sys/class/power_supply/BAT0/energy_now) / $(cat /sys/class/power_supply/BAT0/power_now)" | bc

local awful = require("awful")
local gears = require("gears")
local notifs = require("util.notifs")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local files = require("widget.battery.files")

-- To use colors from beautiful theme put
-- following lines in rc.lua before require("battery"):
--beautiful.tooltip_fg = beautiful.fg_normal
--beautiful.tooltip_bg = beautiful.bg_normal

---Show a warning about battery level
---@param charge number? the current charge
local function show_battery_warning(charge)
  notifs.normal("Houston, we have a problem", {
    icon = files.get_icon("battery-alert"),
    icon_size = dpi(40),
    title = ("Battery is dying (%s%%)"):format(charge or "??"),
    timeout = 5,
    hover_timeout = 0.5,
    position = "bottom_left",
    bg = "#d32f2f",
    fg = "#EEE9EF",
    width = 248,
  })
end
local widget_template = {
  { id = "icon", widget = wibox.widget.imagebox, resize = true, image = files.get_icon("battery") },
  { id = "text", widget = wibox.widget.textbox, text = "100%" },
  layout = wibox.layout.fixed.horizontal,
}
local function should_warn_battery(last_warning_time, status, charge, low_power, low_power_frequency)
  if status == "Charging" then return end
  if charge < 0 or charge > low_power then return end
  local time_since_last = os.difftime(os.time(), last_warning_time)
  if time_since_last < low_power_frequency then return end
end

---Handler for files.get_battery_info
---@param info battery_info
---@return {icon: string, charge: number, status: string}
local function handle_battery_info(info)
  local status = info.status
  local charge = tonumber(info.capacity) or 0
  local batteryIconName = "battery"
  local default_charge = 100

  if status == "Charging" or status == "Full" then batteryIconName = batteryIconName .. "-charging" end

  local roundedCharge = math.floor(charge / 10) * 10
  if roundedCharge == 0 then
    batteryIconName = batteryIconName .. "-outline"
  elseif roundedCharge ~= 100 then
    batteryIconName = batteryIconName .. "-" .. roundedCharge
  end

  local f_charge = math.floor(charge)
  local non_nan_charge = (f_charge ~= f_charge) and default_charge or f_charge
  return {
    icon = files.get_icon(batteryIconName),
    charge = non_nan_charge,
    status = status,
  }
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
  local low_power = args.low_power or 15
  local low_power_frequency = args.low_power_frequency or 300
  local battery_path = args.battery_path or nil
  local last_warning_time = os.time()

  local widget = wibox.widget(widget_template)
  local widget_button = wibox.container.margin(widget, dpi(14), dpi(14), 4, 4)
  local battery_popup = awful.tooltip({
    objects = { widget_button },
    mode = "outside",
    align = "left",
    text = "No Battery Found",
    preferred_positions = { "right", "left", "top", "bottom" },
  })

  local update_widget = function(info)
    local res = handle_battery_info(info)
    widget.icon:set_image(res.icon)
    widget.text:set_text(tostring(res.charge) .. "%")
    battery_popup.text = res.status
    -- if X minutes have elapsed since the last warning
    if should_warn_battery(last_warning_time, res.status, res.charge, low_power, low_power_frequency) then
      last_warning_time = os.time()
      show_battery_warning(res.charge)
    end
  end

  ---@param path string?
  ---@return boolean
  local callback = function(path)
    battery_path = path or battery_path
    if battery_path then files.get_battery_info(battery_path, update_widget) end
    return true
  end

  local timer = gears.timer.new({
    timeout = args.timeout or 15,
    call_now = true,
    autostart = not not battery_path,
    callback = callback,
  })
  if not battery_path then files.find_battery_path(function(path)
    callback(path)
    timer:start()
  end) end

  return widget_button
end

return Battery
