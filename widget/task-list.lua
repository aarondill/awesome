local abutton = require("awful.button")
local aclient = require("awful.client")
local atasklist = require("awful.widget.tasklist")
local atooltip = require("awful.tooltip")
local bind = require("util.bind")
local capi = require("capi")
local clickable_container = require("widget.material.clickable-container")
local gshape = require("gears.shape")
local gtable = require("gears.table")
local handle_error = require("util.handle_error")
local icons = require("theme.icons")
local mat_icon = require("widget.material.icon")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local compat = require("util.awesome.compat")
---Common method to create buttons.
---@param buttons table?
---@param object table
---@return AwesomeButton[]?
local function create_buttons(buttons, object)
  if not buttons then return nil end
  local btns = {}
  for _, b in ipairs(buttons) do
    -- Create a proxy button object: it will receive the real
    -- press and release events, and will propagate them to the
    -- button object the user provided, but with the object as
    -- argument.
    local btn = capi.button({ modifiers = b.modifiers, button = b.button })
    btn:connect_signal("press", bind.with_args(b.emit_signal, b, "press", object))
    btn:connect_signal("release", bind.with_args(b.emit_signal, b, "release", object))
    btns[#btns + 1] = btn
  end

  return btns
end

---Creates tasklist widgets and returns them
---@param buttons AwesomeButton[] a set of `button`s
---@param c AwesomeClientInstance a client
---@param max_width integer? the maximum width of each textbox
---@return { bgb: container.background, tb: widget.textbox, ib: widget.imagebox, tt: awful.tooltip } widgets the set of tasklist widgets
local function create_tasklist_widgets(buttons, c, max_width)
  local bgb = wibox.widget({ --- background
    { -- clickable_container
      { --- layout
        { --- imagebox margin
          { --- image box
            id = "ib",
            widget = wibox.widget.imagebox,
          },
          widget = wibox.container.margin,
          margins = dpi(4),
        },
        { --- textbox margin
          { --- textbox constraint
            { id = "tb", widget = wibox.widget.textbox },
            strategy = "max",
            width = max_width,
            widget = wibox.container.constraint,
          },
          widget = wibox.container.margin,
        },
        { --- close button margin (non-clickable)
          { --- clickable container for close button
            { -- margin for close button (clickable)
              { --- center the close button
                { --- close button
                  image = icons.tag_close,
                  size = dpi(20),
                  widget = mat_icon,
                },
                valign = "center",
                [compat.widget.halign] = "center",
                widget = wibox.container.place,
              },
              margins = dpi(2),
              widget = wibox.container.margin,
            },
            shape = gshape.circle,
            buttons = abutton({}, 1, nil, bind.with_args(c.kill, c)),
            widget = clickable_container,
          },
          margins = dpi(2),
          widget = wibox.container.margin,
        },
        buttons = create_buttons(buttons, c),
        widget = wibox.layout.fixed.horizontal,
      },
      widget = clickable_container,
    },
    widget = wibox.container.background,
  })
  return {
    bgb = bgb,
    tb = bgb:get_children_by_id("tb")[1],
    ib = bgb:get_children_by_id("ib")[1],
    --- Tooltip to display whole title, if it was truncated
    tt = atooltip({ --- tooltip
      mode = "outside",
      align = "bottom",
      delay_show = 1,
    }),
  }
end

---setup and update widgets on the titlebar
---update the widgets, creating them if needed
---@param config TaskListArgs
---@param self awful.widget.tasklist
---@param buttons AwesomeButton[] of buttons
---@param label fun(client: AwesomeClientInstance, textbox: widget.textbox): text:string, bg:string, bg_image:string, icon:CairoSurface, other_args: {shape: gears.shape, shape_border_width: integer, shape_border_color: gears.color}
---@param data table a weekly referenced (keys) table for use in caching
---@param clients AwesomeClientInstance[] a table of the clients to display
local function list_update(config, self, buttons, label, data, clients)
  self:reset()
  for _, c in ipairs(clients) do
    local widgets = data[c] or create_tasklist_widgets(buttons, c, config.max_width)
    if not data[c] then data[c] = widgets end

    local ib, tb, bgb, tt = widgets.ib, widgets.tb, widgets.bgb, widgets.tt
    local text, bg, bg_image, icon, args = label(c, tb)
    args = args or {}

    local error_string = "<i>&lt;Invalid text&gt;</i>"
    if not pcall(tt.set_markup, tt, text) then -- set_markup_silently is not available on awful.tooltip
      tt:set_markup(error_string)
    end
    tt:add_to_object(tb)

    if not tb:set_markup_silently(text) then tb:set_markup(error_string) end

    bgb:set_bg(bg)
    bgb:set_bgimage(bg_image)
    ib:set_image(icon)

    bgb:set_shape(args.shape)

    compat.widget.set_border_width(bgb, compat.widget.get_border_width(args))
    compat.widget.set_border_color(bgb, compat.widget.get_border_color(args))

    self:add(bgb)
  end
end

-- we can use a global set of buttons because they work with their parameters
local tasklist_buttons = gtable.join(
  abutton({}, 1, function(c) ---@param c AwesomeClientInstance
    if c == capi.client.focus then
      c.minimized = true
      return
    end
    -- Without this, the following
    -- :isvisible() makes no sense
    c.minimized = false
    if not c:isvisible() and c.first_tag then c.first_tag:view_only() end
    capi.client.focus = c
    c:raise()
  end),
  -- middle click
  abutton({}, 2, function(c) ---@param c AwesomeClientInstance
    c:kill()
  end),
  -- right click
  abutton({}, 3, function(c) ---@param c AwesomeClientInstance
    c.fullscreen = not c.fullscreen
  end),
  abutton({}, 4, bind.with_args(aclient.focus.byidx, 1)), -- scroll up
  abutton({}, 5, bind.with_args(aclient.focus.byidx, -1)) -- scroll down
)

---@class TaskListArgs
local defaults = {
  ---Passed to awful.widget.tasklist
  screen = nil,
  --- The maximum width of each textbox in the tasklist
  ---@type integer?
  max_width = nil,
}

---@param args TaskListArgs
---@return awful.widget.tasklist
local function TaskList(args)
  local config = gtable.join(defaults, args)
  return atasklist({
    screen = config.screen,
    filter = atasklist.filter.currenttags,
    buttons = tasklist_buttons,
    update_function = bind.with_start_args(handle_error(list_update), config),
    layout = wibox.layout.fixed.horizontal(),
  })
end

return TaskList
