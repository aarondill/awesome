---@diagnostic disable-next-line :undefined-global
local capi = { button = button, client = client }
local awful = require("awful")
local bind = require("util.bind")
local clickable_container = require("widget.material.clickable-container")
local gshape = require("gears.shape")
local gtable = require("gears.table")
local handle_error = require("util.handle_error")
local icons = require("theme.icons")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local compat = require("util.compat")
---Common method to create buttons.
---@param buttons table?
---@param object table
---@return table?
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

---Return container if if_bool is true, else return container[index]
---@param container table pass to wibox.widget
---@param if_bool unknown? boolean to check
---@param index unknown? The index to get object from. Defaults to 1.
local function optional_container(if_bool, container, index)
  index = index or 1
  assert(type(container or {}) == "table", "container must be a table")

  if not container or if_bool then
    return container
  else
    return container[index]
  end
end
---Creates tasklist widgets and returns them
---@param buttons table a set of `button`s
---@param c table a client
---@param max_width integer the maximum width of each textbox
---@return table widgets the set of tasklist widgets
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
          optional_container(max_width, { --- textbox constraint
            { id = "tb", widget = wibox.widget.textbox },
            strategy = "max",
            width = max_width,
            widget = wibox.container.constraint,
          }),
          widget = wibox.container.margin,
        },
        { --- close button margin (non-clickable)
          { --- clickable container for close button
            { -- margin for close button (clickable)
              { --- center the close button
                { --- close button
                  image = icons.tag_close,
                  forced_height = dpi(20),
                  forced_width = dpi(20),
                  widget = wibox.widget.imagebox,
                },
                valign = "center",
                [compat.widget.halign] = "center",
                widget = wibox.container.place,
              },
              margins = dpi(2),
              widget = wibox.container.margin,
            },
            shape = gshape.circle,
            buttons = awful.button({}, 1, nil, bind.with_args(c.kill, c)),
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
    tt = awful.tooltip({ --- tooltip
      mode = "outside",
      align = "bottom",
      delay_show = 1,
    }),
  }
end

---setup and update widgets on the titlebar
---update the widgets, creating them if needed
---@param config TaskListArgs
---@param self table widget
---@param buttons table of buttons
---@param label fun(client:table, textbox: table): text:string, bg:string, bg_image:string, icon:string
---@param data table a weekly referenced (keys) table for use in caching
---@param clients table a table of the clients to display
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
    ib.image = icon

    bgb.shape = args.shape

    compat.widget.set_border_width(bgb, compat.widget.get_border_width(args))
    compat.widget.set_border_color(bgb, compat.widget.get_border_color(args))

    self:add(bgb)
  end
end

-- we can use a global set of buttons because they work with their parameters
local tasklist_buttons = gtable.join(
  awful.button({}, 1, function(c)
    if c == capi.client.focus then
      c.minimized = true
    else
      -- Without this, the following
      -- :isvisible() makes no sense
      c.minimized = false
      if not c:isvisible() and c.first_tag then c.first_tag:view_only() end
      -- This will also un-minimize
      -- the client, if needed
      capi.client.focus = c
      c:raise()
    end
  end),
  awful.button({}, 2, function(c)
    c.kill(c)
  end),
  awful.button({}, 4, function()
    awful.client.focus.byidx(1)
  end),
  awful.button({}, 5, function()
    awful.client.focus.byidx(-1)
  end)
)

---@class TaskListArgs
local defaults = {
  ---Passed to awful.widget.tasklist
  screen = nil,
  --- The maximum width of each textbox in the tasklist
  ---@type integer?
  max_width = nil,
}
---@class TaskList

---@param args TaskListArgs
---@return TaskList
local function TaskList(args)
  local config = gtable.join(defaults, args)
  local tl = awful.widget.tasklist({
    screen = config.screen,
    filter = awful.widget.tasklist.filter.currenttags,
    buttons = tasklist_buttons,
    update_function = bind.with_start_args(handle_error(list_update), config),
    layout = wibox.layout.fixed.horizontal(),
  })
  return tl
end

return TaskList
