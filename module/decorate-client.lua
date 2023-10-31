--- This module implements dynamic client rendering
--- It currently only sets the border_width and corner rounding depending on the number of currently drawn clients.
--- Also handles hiding/showing the top bar

local alayout = require("awful.layout")
local beautiful = require("beautiful")
local capi = require("capi")
local gtimer = require("gears.timer")
local quake = require("module.quake")
local table_utils = require("util.table")

local function shape_rounded_rect(cr, w, h)
  return require("gears.shape").rounded_rect(cr, w, h, 8)
end
---@param client AwesomeClientInstance
---@param render_maximized boolean
local function renderClient(client, render_maximized)
  if quake:client_is_quake(client) then return end
  if client.skip_decoration then return end

  if client.rendering_mode == render_maximized then return end -- Check cached.
  client.rendering_mode = render_maximized ---@diagnostic disable-line :inject-field this is an injected field

  if render_maximized then
    client.border_width = 0
    client.shape = nil -- If nil, draws as a rectangle
    return
  end

  client.border_width = beautiful.border_width
  client.shape = shape_rounded_rect
end

local changesOnScreenPending = false

local function is_tag_maximized(tag)
  if not tag then return false end
  if tag.layout == alayout.suit.max then return true end
  if tag.layout == alayout.suit.max.fullscreen then return true end
end
local function changesOnScreen(currentScreen) ---@param currentScreen AwesomeScreenInstance
  local managed_clients = table_utils.filter(currentScreen.clients, function(_, c)
    return c.valid and not c.skip_decoration and not c.hidden and not quake:client_is_quake(c)
  end)

  local tag_is_max = is_tag_maximized(currentScreen.selected_tag)
  local render_maximized = tag_is_max or #managed_clients <= 1
  local show_top_bar = not tag_is_max or #managed_clients == 0 -- If the tag is maximized, don't show the top bar -- unless no clients.
  for _, client in ipairs(managed_clients) do
    renderClient(client, client.fullscreen or render_maximized)
    if client.fullscreen then show_top_bar = false end -- If *any* client is fullscreen, the top panel should be hidden
  end

  if currentScreen.top_panel then --- Hide bars when app go fullscreen
    currentScreen.top_panel.visible = show_top_bar
  end

  changesOnScreenPending = false
end

local function clientCallback(client) ---@param client AwesomeClientInstance
  if changesOnScreenPending then return end
  if client.skip_decoration then return end
  local s = client.screen
  if not s then return end

  changesOnScreenPending = true
  return gtimer.delayed_call(function()
    return changesOnScreen(s)
  end)
end
local function tagCallback(tag) ---@param tag AwesomeTagInstance
  if changesOnScreenPending then return end
  local s = tag.screen
  if not s then return end

  changesOnScreenPending = true
  return gtimer.delayed_call(function()
    return changesOnScreen(s)
  end)
end

local compat = require("util.compat")
capi.client.connect_signal(compat.signal.manage, clientCallback)
capi.client.connect_signal(compat.signal.unmanage, clientCallback)
capi.client.connect_signal("property::hidden", clientCallback)
capi.client.connect_signal("property::minimized", clientCallback)
capi.client.connect_signal("property::fullscreen", clientCallback)
capi.client.connect_signal("tagged", clientCallback)

capi.tag.connect_signal("property::selected", tagCallback)
capi.tag.connect_signal("property::layout", tagCallback)
