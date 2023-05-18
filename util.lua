local M = {}
local naughty = require("naughty")
local gears = require("gears")

---naughty.notify with default error styles
---@param args table same as naughty.notify
function M.err(args)
	naughty.notify(gears.table.crush({
		preset = naughty.config.presets.critical,
	}, args))
end
local awful = require("awful")
local wibox = require("wibox")

---@see source: https://bitbucket.org/grumph/home_config/src/master/.config/awesome/helpers/click_to_hide.lua
--- Click outside of a popup to hide it
---@param widget table the widget to hide
---@param hide_fct function? the function to call when the widget is to be hidden, if nil, visible is set to false
---@param only_outside boolean? only hide if clicked outside of the widget. if false (default), hides on any click
function M.click_to_hide(widget, hide_fct, only_outside)
	only_outside = only_outside or false

	hide_fct = hide_fct
		or function(object)
			if only_outside and object == widget then
				return
			end
			widget.visible = false
		end

	local click_bind = awful.button({}, 1, hide_fct)

	local function manage_signals(w)
		if not w.visible then
			wibox.disconnect_signal("button::press", hide_fct)
			client.disconnect_signal("button::press", hide_fct)
			awful.mouse.remove_global_mousebinding(click_bind)
		else
			awful.mouse.append_global_mousebinding(click_bind)
			client.connect_signal("button::press", hide_fct)
			wibox.connect_signal("button::press", hide_fct)
		end
	end

	-- when the widget is visible, we hide it on button press
	widget:connect_signal("property::visible", manage_signals)

	function widget.disconnect_click_to_hide()
		widget:disconnect_signal("property::visible", manage_signals)
	end
end

---@see source: https://bitbucket.org/grumph/home_config/src/master/.config/awesome/helpers/click_to_hide.lua
--- Click outside of a menu to hide it
---@param menu table the menu to hide
---@param hide_fct function? the function to call when the widget is to be hidden, if nil, visible is set to false
---@param only_outside boolean? only hide if clicked outside of the widget. if false (default), hides on any click
function M.click_to_hide_menu(menu, hide_fct, only_outside)
	M.click_to_hide(menu.wibox, hide_fct or function()
		menu:hide()
	end, only_outside)
end

return M
