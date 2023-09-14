---@diagnostic disable-next-line :undefined-global
local capi = { client = client }
local awful = require("awful")
local beautiful = require("beautiful")
local bind = require("util.bind")
local compat = require("util.compat")
local gshape = require("gears.shape")
local gtimer = require("gears.timer")
local quake = require("module.quake")

local function renderClient(client, mode)
  if quake:client_is_quake(client) then return end
  if client.skip_decoration or (client.rendering_mode == mode) then return end
  if client.is_new then
    client.floating = false
    client.maximized = false
    client.above = false
    client.below = false
    client.ontop = false
    client.sticky = false
    client.maximized_horizontal = false
    client.maximized_vertical = false
    client.is_new = false
  end

  client.rendering_mode = mode
  if client.rendering_mode == "maximized" then
    client.border_width = 0
    client.shape = gshape.rectangle
  elseif client.rendering_mode == "tiled" then
    client.border_width = beautiful.border_width
    client.shape = function(cr, w, h)
      gshape.rounded_rect(cr, w, h, 8)
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
    if not client.skip_decoration and not client.hidden and not quake:client_is_quake(client) then
      table.insert(clientsToManage, client)
    end
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
      gtimer.delayed_call(bind.with_args(changesOnScreen, screen))
    end
  end
end

local function tagCallback(tag)
  if not changesOnScreenCalled then
    if tag.screen then
      changesOnScreenCalled = true
      local screen = tag.screen
      gtimer.delayed_call(bind.with_args(changesOnScreen, screen))
    end
  end
end

capi.client.connect_signal(compat.signal.manage, function(c)
  if not awesome.startup then c.is_new = true end
  clientCallback(c)
end)
capi.client.connect_signal(compat.signal.unmanage, clientCallback)

capi.client.connect_signal("property::hidden", clientCallback)

capi.client.connect_signal("property::minimized", clientCallback)

capi.client.connect_signal("property::fullscreen", function(c)
  if c.fullscreen then
    renderClient(c, "maximized")
  else
    clientCallback(c)
  end
end)

awful.tag.attached_connect_signal(nil, "property::selected", tagCallback)

awful.tag.attached_connect_signal(nil, "property::layout", tagCallback)
