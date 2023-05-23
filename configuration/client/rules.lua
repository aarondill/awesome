local awful = require("awful")
local gears = require("gears")
local client_keys = require("configuration.keys.client")
local client_buttons = require("configuration.client.buttons")

-- Rules
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			focus = awful.client.focus.filter,
			raise = true,
			keys = client_keys,
			buttons = client_buttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
			floating = false,
			maximized = false,
			above = false,
			below = false,
			ontop = false,
			sticky = false,
			maximized_horizontal = false,
			maximized_vertical = false,
			size_hints_honor = false, -- No minimum size, no offscreen windows
		},
		callback = function(c)
			c:grant("autoactivate", "history")
			c:grant("autoactivate", "switch_tag")
		end,
	},
	-- Enable titlebars on normal clients
	-- {
	-- 	rule_any = { type = { "normal", "dialog" } },
	-- 	callback = function(c)
	-- 		-- This *must* be set in a callback to preserve the property outside of the request::titlebars
	-- 		c.titlebars_enabled = true
	-- 	end,
	-- },
	-- Dialog clients should float and have rounded corners
	{
		rule_any = { type = { "dialog" }, class = { "Wicd-client.py", "calendar.google.com" } },
		properties = {
			placement = awful.placement.centered,
			ontop = true,
			floating = true,
			drawBackdrop = true,
			shape = function()
				return function(cr, w, h)
					gears.shape.rounded_rect(cr, w, h, 8)
				end
			end,
			skip_decoration = true,
		},
	},
}
