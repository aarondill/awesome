local awful = require("awful")
local capi = require("capi")
local gtable = require("gears.table")
local layouts = require("configuration.layouts")
local tags = require("configuration.tags")

if awful.layout.append_default_layouts then -- Added in v5
  capi.tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts(require("configuration.layouts"))
  end)
else -- v4. Breaks in v5
  awful.layout.layouts = require("configuration.layouts")
end

awful.screen.connect_for_each_screen(function(s)
  for i, tag in pairs(tags) do
    if not tag then goto continue end
    if type(tag) ~= "table" then
      if type(tag) == "function" then
        -- Screen, index, array
        tag = tag(s, i, tags)
      elseif type(tag) == "string" or type(tag) == "number" then
        tag = { name = tostring(tag) }
      else
        tag = {}
      end
    end

    local params = gtable.crush({
      name = i,
      layout = layouts[1] or awful.layout.suit.tile,
      gap_single_client = true,
      gap = 4,
      screen = s,
      selected = i == 1,
    }, tag or {})

    -- icon_only not specified, but icon is. Default to only icon.
    if tag.icon_only == nil and tag.icon and not tag.name then params.icon_only = true end

    awful.tag.add(params.name, params)
    ::continue::
  end
end)

awful.tag.attached_connect_signal(nil, "property::layout", function(t)
  local currentLayout = awful.tag.getproperty(t, "layout")
  if currentLayout == awful.layout.suit.max then
    t.gap = 0
  else
    t.gap = 4
  end
end)
