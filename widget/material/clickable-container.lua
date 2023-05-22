local wibox = require("wibox")

local function build(widget)
	local container = wibox.widget({
		widget,
		widget = wibox.container.background,
	})
	local saved_cursor, containing_wibox

	container:connect_signal("mouse::enter", function()
		container.bg = "#ffffff11"
		-- Hm, no idea how to get the wibox from this signal's arguments...
		local w = mouse.current_wibox
		if w and not w.is_moused_over then
			saved_cursor, containing_wibox = w.cursor, w
			-- Save the state to avoid race conditions between
			-- multiple clickable widgets in the same wibox
			w.is_moused_over = true
			w.cursor = "hand1"
		end
	end)

	container:connect_signal("mouse::leave", function()
		container.bg = "#ffffff00"
		if containing_wibox then
			containing_wibox.cursor = saved_cursor
			containing_wibox.is_moused_over = false
			containing_wibox = nil
		end
	end)

	container:connect_signal("button::press", function()
		container.bg = "#ffffff22"
	end)

	container:connect_signal("button::release", function()
		container.bg = "#ffffff11"
	end)

	return container
end

return build
