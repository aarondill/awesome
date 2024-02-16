local abutton = require("awful.button")
local alayout = require("awful.layout")
local amouse = require("awful.mouse")
local atitlebar = require("awful.titlebar")
local capi = require("capi")
local compat = require("util.awesome.compat")
local gtable = require("gears.table")
local quake = require("module.quake")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi

-- Add a titlebar if titlebars_enabled is set to true in the rules.
local function render_titlebars(c)
  -- buttons for the titlebar
  local buttons = gtable.join(
    abutton({}, 1, function()
      c:emit_signal("request::activate", "titlebar", { raise = true })
      amouse.client.move(c)
    end),
    abutton({}, 3, function()
      c:emit_signal("request::activate", "titlebar", { raise = true })
      amouse.client.resize(c)
    end)
  )

  atitlebar(c):setup({
    {
      { -- Left
        widget = atitlebar.widget.iconwidget(c),
        buttons = buttons,
      },
      { -- Title
        widget = atitlebar.widget.titlewidget(c),
        buttons = buttons,
        [compat.widget.halign] = "center",
      },
      { -- Right
        atitlebar.widget.minimizebutton(c),
        atitlebar.widget.maximizedbutton(c),
        atitlebar.widget.closebutton(c),
        spacing = dpi(6),
        layout = wibox.layout.fixed.horizontal,
      },
      layout = wibox.layout.align.horizontal,
    },
    left = dpi(6),
    right = dpi(6),
    top = dpi(4),
    bottom = dpi(4),
    widget = wibox.container.margin,
  })
end

local function should_show_titlebars(c)
  if c.requests_no_titlebar then return false end -- No titlebars
  if not quake:client_is_quake(c) then -- quake is always floating -- handle other ways
    if c.floating then return true end -- Client is floating
    if c.first_tag and c.first_tag.layout == alayout.suit.floating then return true end -- layout is floating
  end

  -- NOTE: This must be set manually (in a callback),
  -- the value of `properties: {titlebars_enabled = true}`
  -- is lost after request::titlebars event
  if c.titlebars_enabled then return true end -- Titlebars enabled
  return false -- default to hide
end

-- Show or hide the titlebar according to requests_no_titlebar and titlebars_enabled
local function show_titlebars(c)
  if should_show_titlebars(c) then return atitlebar.show(c, "top") end
  return atitlebar.hide(c, "top")
end

-- If client requests not to show the titlebar
capi.client.connect_signal("property::requests_no_titlebar", show_titlebars) -- it now requests no titlebars
capi.client.connect_signal("request::tag", show_titlebars) -- A tag has changed
capi.client.connect_signal("property::floating", show_titlebars) -- Handle floating changes
capi.client.connect_signal("property::titlebars_enabled", show_titlebars) -- The user has indicated that titlebars should be shown
-- Show titlebars on tags with the floating layout
capi.tag.connect_signal("property::layout", function(t)
  for _, c in pairs(t:clients()) do
    show_titlebars(c)
  end
end)
capi.client.connect_signal("request::titlebars", render_titlebars)
