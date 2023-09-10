local awful = require("awful")
local bind = require("util.bind")
local clickable_container = require("widget.material.clickable-container")
local gshape = require("gears.shape")
local gtable = require("gears.table")
local handle_error = require("util.handle_error")
local icons = require("theme.icons")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local capi = { button = button }
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

---Creates tasklist widgets and returns them
---@param buttons table a set of `button`s
---@param c table a client
---@param max_width integer the maximum width of each textbox
---@return table widgets the set of tasklist widgets
local function create_tasklist_widgets(buttons, c, max_width)
  local ib = wibox.widget.imagebox() --- imagebox
  local tb = wibox.widget.textbox() --- textbox
  local tbm = wibox.widget({ --- textbox margin
    { --- textbox constraint
      tb,
      strategy = "max",
      width = max_width,
      widget = wibox.container.constraint,
    },
    left = dpi(4),
    widget = wibox.container.margin,
  })
  local ibm = wibox.widget({ --- imagebox margin
    ib,
    widget = wibox.container.margin,
    margins = dpi(4),
  })
  local bgb = wibox.widget({ --- background
    { -- clickable_container
      { --- layout
        ibm,
        tbm,
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
                [awesome.version <= "v4.3" and "align" or "halign"] = "center",
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

  -- Tooltip to display whole title, if it was truncated
  local tt = awful.tooltip({ --- tooltip
    objects = { tb },
    mode = "outside",
    align = "bottom",
    delay_show = 1,
  })
  return {
    ib = ib,
    tb = tb,
    bgb = bgb,
    tbm = tbm,
    ibm = ibm,
    tt = tt,
  }
end

---setup and update widgets on the titlebar
---@param config TaskListArgs
---@param self table widget
---@param buttons table of buttons
---@param label fun(client:table, textbox: table): text:string, bg:string, bg_image:string, icon:string
---@param data table a weekly referenced (keys) table for use in caching
---@param clients table a table of the clients to display
local function list_update(config, self, buttons, label, data, clients)
  -- update the widgets, creating them if needed
  self:reset()
  for _, c in ipairs(clients) do
    local cache = data[c]

    local widgets = cache or create_tasklist_widgets(buttons, c, config.max_width)
    local ib, tb, bgb, tbm, ibm, tt = widgets.ib, widgets.tb, widgets.bgb, widgets.tbm, widgets.ibm, widgets.tt
    if not cache then
      data[c] = {
        ib = ib,
        tb = tb,
        bgb = bgb,
        tbm = tbm,
        ibm = ibm,
        tt = tt,
      }
    end

    local text, bg, bg_image, icon, args = label(c, tb)
    args = args or {}

    if text == nil or text == "" then
      tbm:set_margins(0)
    else
      -- Needed to update geometry of the other widgets
      if tt.textbox:set_markup_silently(text) then
        tt:set_markup(text)
      else
        tt:set_markup("<i>&lt;Invalid text&gt;</i>")
      end
      tt:add_to_object(tb)
      if not tb:set_markup_silently(text) then tb:set_markup("<i>&lt;Invalid text&gt;</i>") end
    end
    bgb:set_bg(bg)
    bgb:set_bgimage(bg_image)
    if icon then
      ib.image = icon
    else
      ibm:set_margins(0)
    end

    bgb.shape = args.shape

    if awesome.version <= "v4.3" then
      bgb.shape_border_width = args.shape_border_width
      bgb.shape_border_color = args.shape_border_color
    else
      bgb.border_width = args.border_width
      bgb.border_color = args.border_color
    end

    self:add(bgb)
  end
end

-- we can use a global set of buttons because they work with their parameters
local tasklist_buttons = gtable.join(
  awful.button({}, 1, function(c)
    if c == client.focus then
      c.minimized = true
    else
      -- Without this, the following
      -- :isvisible() makes no sense
      c.minimized = false
      if not c:isvisible() and c.first_tag then c.first_tag:view_only() end
      -- This will also un-minimize
      -- the client, if needed
      client.focus = c
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
