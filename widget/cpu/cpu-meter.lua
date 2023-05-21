local wibox = require("wibox")
local mat_icon = require("widget.material.icon")
local icons = require("theme.icons")
local watch = require("awful.widget.watch")
local dpi = require("beautiful").xresources.apply_dpi

---@class CPUWidgetConfig
---The number of decimal places to display in the percentage (default: 0).
---@field precision integer
---How often to update the widget in seconds (default: 15).
---@field timeout integer?
---The program to spawn on click of the widget. If nil, the widget will not be clickable.
---@field spawn_on_click string?

---Create a new CPU usage widget
---@param args CPUWidgetConfig?
---@return table
function CPU(args)
	args = args or {}
	local cpu_total_prev = 0
	local idle_prev = 0

	local text_box = wibox.widget({
		widget = wibox.widget.textbox,
		text = "default",
	})

	watch([[bash -c "cat /proc/stat | grep '^cpu '"]], args.timeout or 15, function(_, stdout)
		local rem = stdout:match("cpu%s+(.*)")
		local user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice
		-- find values, even if not exist
		user, rem = rem:match("(%d+)(.*)")
		nice, rem = rem:match("(%d+)(.*)")
		system, rem = rem:match("(%d+)(.*)")
		idle, rem = rem:match("(%d+)(.*)")
		iowait, rem = rem:match("(%d+)(.*)")
		irq, rem = rem:match("(%d+)(.*)")
		softirq, rem = rem:match("(%d+)(.*)")
		steal, rem = rem:match("(%d+)(.*)")
		guest, rem = rem:match("(%d+)(.*)")
		guest_nice, rem = rem:match("(%d+)(.*)")

		local cpu_total = user + nice + system + idle + iowait + irq + softirq + steal + guest + guest_nice

		-- Get the delta between two reads
		local diff_cpu = cpu_total - cpu_total_prev
		-- Get the idle time delta
		local diff_idle = idle - idle_prev
		-- Calc time spent working
		local cpu_used = diff_cpu - diff_idle
		-- Calc percentage
		local cpu_usage = 100 * cpu_used / diff_cpu

		-- Round to percentage
		text_box:set_text(string.format("%." .. (args.precision or 0) .. "f%%", cpu_usage))

		cpu_total_prev = cpu_total
		idle_prev = idle
		collectgarbage("collect")
	end)

	local cpu_meter = wibox.widget({
		wibox.widget({
			icon = icons.chart,
			size = dpi(24),
			widget = mat_icon,
		}),
		text_box,
		widget = wibox.layout.fixed.horizontal,
	})

	return cpu_meter
end
return CPU
