-- Based initially on:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/battery-widget
-- Time remaining came from acpi source code
local require = require("util.rel_require")

local Icon = require("widget.material.icon")
local atooltip = require("awful.tooltip")
local calculate_time_remaining = require(..., "time") ---@module "widget.battery.time"
local files = require(..., "files") ---@module "widget.battery.files"
local gtimer = require("gears.timer")
local handle_error = require("util.handle_error")
local notifs = require("util.notifs")
local strings = require("util.strings")
local wibox = require("wibox")

-- To use colors from beautiful theme put
-- following lines in rc.lua before require("battery"):
--beautiful.tooltip_fg = beautiful.fg_normal
--beautiful.tooltip_bg = beautiful.bg_normal

---Show a warning about battery level
---@param charge number? the current charge
local function show_battery_warning(charge)
  notifs.warn("Houston, we have a problem", {
    icon = files.get_icon("battery-alert"),
    title = ("Battery is dying (%s%%)"):format(charge or "??"),
  })
end
local widget_template = {
  { id = "icon", widget = Icon, icon = files.get_icon("battery") },
  { id = "text", widget = wibox.widget.textbox, text = "100%" },
  layout = wibox.layout.fixed.horizontal,
}

local function should_warn_battery(last_warning_time, status, charge, low_power, low_power_frequency)
  if status == "Charging" then return end
  if not charge or charge < 0 or charge > low_power then return end
  local time_since_last = os.difftime(os.time(), last_warning_time)
  return time_since_last >= low_power_frequency
end

---@param status string?
---@param charge number?
---@return string
local function get_battery_icon_name(status, charge)
  local battery_icon = "battery"

  if not charge then return battery_icon .. "-unknown" end

  if status == "charging" or status == "full" then battery_icon = battery_icon .. "-charging" end

  local roundedCharge = math.floor(charge / 10) * 10
  if roundedCharge == 100 then return battery_icon end
  if roundedCharge == 0 then return battery_icon .. "-outline" end
  return ("%s-%s"):format(battery_icon, roundedCharge)
end

---Handler for files.get_battery_info
---@param info battery_info
---@return {icon: string, charge?: number, status: string}
local function handle_battery_info(info)
  local charge = info.capacity and tonumber(info.capacity)
  local status = info.status and string.lower(info.status)
  local remaining = calculate_time_remaining(info)
  local battery_icon_name = get_battery_icon_name(status, charge)
  return {
    icon = files.get_icon(battery_icon_name),
    charge = charge and math.floor(charge),
    status = ("%s%s"):format(strings.first_upper(status or ""), remaining and ", " .. remaining or ""),
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
  local last_warning_time = 0

  local widget = wibox.widget(widget_template)
  local battery_popup = atooltip({
    objects = { widget },
    mode = "outside",
    align = "left",
    text = "No Battery Found",
    preferred_positions = { "right", "left", "top", "bottom" },
  })

  ---@param info battery_info
  local update_widget = function(info)
    local res = handle_battery_info(info)
    local icon = widget:get_children_by_id("icon")[1]
    local text = widget:get_children_by_id("text")[1]

    icon:set_image(res.icon)
    text:set_text(tostring(res.charge or "??") .. "%")
    battery_popup.text = strings.first_upper(res.status)
    -- if X minutes have elapsed since the last warning
    if should_warn_battery(last_warning_time, info.status, res.charge, low_power, low_power_frequency) then
      last_warning_time = os.time()
      show_battery_warning(res.charge)
    end
  end

  ---@return true
  local callback = function()
    if battery_path then files.get_battery_info(battery_path, handle_error(update_widget)) end
    return true
  end

  local timer = gtimer.new({
    timeout = args.timeout or 15,
    call_now = true,
    autostart = not not battery_path,
    callback = callback,
  })
  require("module.suspend-listener").register_listener(function(is_before)
    if is_before then return end
    timer:again() -- Restart the timer
    return callback()
  end, { weak = widget })

  if not battery_path then
    files.find_battery_path(function(path)
      battery_path = path or battery_path
      callback()
      timer:start()
    end)
  end

  return widget
end

return Battery
