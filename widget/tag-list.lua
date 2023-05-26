local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local capi = { button = button }
local clickable_container = require("widget.material.clickable-container")
local modkey = require("configuration.keys.mod").modKey
--- Common method to create buttons.
-- @tab buttons
-- @param object
-- @treturn table
local function create_buttons(buttons, object)
	if buttons then
		local btns = {}
		for _, b in ipairs(buttons) do
			-- Create a proxy button object: it will receive the real
			-- press and release events, and will propagate them to the
			-- button object the user provided, but with the object as
			-- argument.
			local btn = capi.button({ modifiers = b.modifiers, button = b.button })
			btn:connect_signal("press", function()
				b:emit_signal("press", object)
			end)
			btn:connect_signal("release", function()
				b:emit_signal("release", object)
			end)
			btns[#btns + 1] = btn
		end

		return btns
	end
end

--- Update the taglist.
---@param taglist_widget table the widget.
---@param buttons table
---@param label fun(object: table):  text:string, bg: string, bg_image:string, icon:string Function to generate label parameters from an object.
---@param data table Current data/cache, indexed by objects.
---@param objects table Objects to be displayed / updated.
---@param args table? The table arguments
local function list_update(taglist_widget, buttons, label, data, objects, args)
	-- update the widgets, creating them if needed
	taglist_widget:reset()
	for _, object in ipairs(objects) do
		local cache = data[object]
		local imagebox, textbox, background_box, textbox_margin, imagebox_margin, layout, bg_clickable
		if cache then
			imagebox = cache.ib
			textbox = cache.tb
			background_box = cache.bgb
			textbox_margin = cache.tbm
			imagebox_margin = cache.ibm
		else
			imagebox = wibox.widget.imagebox()
			textbox = wibox.widget.textbox()
			background_box = wibox.container.background()
			textbox_margin = wibox.container.margin(textbox, dpi(6), dpi(6))
			imagebox_margin = wibox.container.margin(imagebox, dpi(6), dpi(6), dpi(6), dpi(6))
			layout = wibox.layout.fixed.horizontal()
			bg_clickable = clickable_container()

			-- All of this is added in a fixed widget
			layout:fill_space(true)
			layout:add(imagebox_margin)
			layout:add(textbox_margin)

			-- l:add(tbm)
			bg_clickable:set_widget(layout)

			-- And all of this gets a background
			background_box:set_widget(bg_clickable)

			background_box:buttons(create_buttons(buttons, object))

			data[object] = {
				ib = imagebox,
				tb = textbox,
				bgb = background_box,
				tbm = textbox_margin,
				ibm = imagebox_margin,
			}
		end

		local text, bg, bg_image, icon, item_args = label(object)
		item_args = item_args or {}

		-- If no text, or icon_only mode don't show the textbox margin
		if text == nil or text == "" or taglist_widget.icon_only then
			textbox_margin:set_margins(0)
		else
			if not textbox:set_markup_silently(text) then
				textbox:set_markup("<i>&lt;Invalid text&gt;</i>")
			end
		end
		background_box:set_bg(bg)
		background_box:set_bgimage(bg_image)
		if icon then
			imagebox.image = icon
		else
			imagebox_margin:set_margins(0)
		end

		background_box.shape = item_args.shape
		background_box.shape_border_width = item_args.shape_border_width
		background_box.shape_border_color = item_args.shape_border_color

		taglist_widget:add(background_box)
	end
end

local TagList = function(s)
	return awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = gears.table.join(
			awful.button({}, 1, function(t)
				t:view_only()
			end),
			awful.button({ modkey }, 1, function(t)
				if client.focus then
					client.focus:move_to_tag(t)
					t:view_only()
				end
			end),
			awful.button({}, 3, awful.tag.viewtoggle),
			awful.button({ modkey }, 3, function(t)
				if client.focus then
					client.focus:toggle_tag(t)
				end
			end),
			awful.button({}, 4, function(t)
				awful.tag.viewprev(t.screen)
			end),
			awful.button({}, 5, function(t)
				awful.tag.viewnext(t.screen)
			end)
		),
		style = {},
		update_function = list_update,
	})
end
return TagList
