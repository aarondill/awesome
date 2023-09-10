local awful = require("awful")
local compat = require("util.compat")
local gtable = require("gears.table")
local wibox = require("wibox")

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
  -- buttons for the titlebar
  local buttons = gtable.join(
    awful.button({}, 1, function()
      c:emit_signal("request::activate", "titlebar", { raise = true })
      awful.mouse.client.move(c)
    end),
    awful.button({}, 3, function()
      c:emit_signal("request::activate", "titlebar", { raise = true })
      awful.mouse.client.resize(c)
    end)
  )

  awful.titlebar(c):setup({
    { -- Left
      awful.titlebar.widget.iconwidget(c),
      buttons = buttons,
      layout = wibox.layout.fixed.horizontal,
    },
    { -- Middle
      { -- Title
        widget = awful.titlebar.widget.titlewidget(c),
        [compat.widget.halign] = "center",
      },
      buttons = buttons,
      layout = wibox.layout.flex.horizontal,
    },
    { -- Right
      awful.titlebar.widget.floatingbutton(c),
      awful.titlebar.widget.maximizedbutton(c),
      awful.titlebar.widget.stickybutton(c),
      awful.titlebar.widget.ontopbutton(c),
      awful.titlebar.widget.closebutton(c),
      layout = wibox.layout.fixed.horizontal(),
    },
    layout = wibox.layout.align.horizontal,
  })
end)

-- Show or hide the titlebar according to requests_no_titlebar and titlebars_enabled
local function renderTitlebars(client)
  if client.requests_no_titlebar then
    awful.titlebar.hide(client, "top")
  -- NOTE: This must be set manually (in a callback),
  -- the value of `properties: {titlebars_enabled = true}`
  -- is lost after request::titlebars event
  elseif client.titlebars_enabled then
    awful.titlebar.show(client, "top")
  end
end

-- If client requests not to show the titlebar
client.connect_signal("property::requests_no_titlebar", renderTitlebars)
-- The user has indicated that titlebars should be shown
client.connect_signal("property::titlebars_enabled", renderTitlebars)
