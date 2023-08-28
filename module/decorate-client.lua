local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local quake_class = require("module.quake").class

local function renderClient(client, mode)
  if client.instance == quake_class then return end
  if client.skip_decoration or (client.rendering_mode == mode) then return end

  client.rendering_mode = mode
  client.floating = false
  client.maximized = false
  client.above = false
  client.below = false
  client.ontop = false
  client.sticky = false
  client.maximized_horizontal = false
  client.maximized_vertical = false

  if client.rendering_mode == "maximized" then
    client.border_width = 0
    client.shape = function(cr, w, h)
      gears.shape.rectangle(cr, w, h)
    end
  elseif client.rendering_mode == "tiled" then
    client.border_width = beautiful.border_width
    client.shape = function(cr, w, h)
      gears.shape.rounded_rect(cr, w, h, 8)
    end
  end
end

local changesOnScreenCalled = false

local function changesOnScreen(currentScreen)
  local tagIsMax = currentScreen.selected_tag ~= nil
    and (
      currentScreen.selected_tag.layout == awful.layout.suit.max
      or currentScreen.selected_tag.layout == awful.layout.suit.max.fullscreen
    )
  local clientsToManage = {}

  for _, client in pairs(currentScreen.clients or {}) do
    if not client.skip_decoration and not client.hidden then table.insert(clientsToManage, client) end
  end

  if tagIsMax or #clientsToManage == 1 then
    currentScreen.client_mode = "maximized"
  else
    currentScreen.client_mode = "tiled"
  end

  for _, client in pairs(clientsToManage) do
    renderClient(client, currentScreen.client_mode)
  end
  changesOnScreenCalled = false
end

local function clientCallback(client)
  if not changesOnScreenCalled then
    if not client.skip_decoration and client.screen then
      changesOnScreenCalled = true
      local screen = client.screen
      gears.timer.delayed_call(function()
        changesOnScreen(screen)
      end)
    end
  end
end

local function tagCallback(tag)
  if not changesOnScreenCalled then
    if tag.screen then
      changesOnScreenCalled = true
      local screen = tag.screen
      gears.timer.delayed_call(function()
        changesOnScreen(screen)
      end)
    end
  end
end

local manage_signal = awesome.version <= "v4.3" and "manage" or "request::manage"
client.connect_signal(manage_signal, clientCallback)

local unmanage_signal = awesome.version <= "v4.3" and "unmanage" or "request::unmanage"
client.connect_signal(unmanage_signal, clientCallback)

client.connect_signal("property::hidden", clientCallback)

client.connect_signal("property::minimized", clientCallback)

client.connect_signal("property::fullscreen", function(c)
  if c.fullscreen then
    renderClient(c, "maximized")
  else
    clientCallback(c)
  end
end)

awful.tag.attached_connect_signal(nil, "property::selected", tagCallback)

awful.tag.attached_connect_signal(nil, "property::layout", tagCallback)
