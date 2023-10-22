local awful = require("awful")
local beautiful = require("beautiful")
local bind = require("util.bind")
local capi = require("capi")
local compat = require("util.compat")
local gshape = require("gears.shape")
local gtimer = require("gears.timer")
local quake = require("module.quake")

---@param client AwesomeClientInstance
---@param rounded_corners boolean
local function renderClient(client, rounded_corners)
  if quake:client_is_quake(client) then return end
  if client.skip_decoration then return end ---@diagnostic disable-line :undefined-field this is an injected field

  if client.rendering_mode == rounded_corners then return end -- Check cached.
  client.rendering_mode = rounded_corners ---@diagnostic disable-line :inject-field this is an injected field

  if not capi.awesome.startup then
    client.floating = false
    client.maximized = false
    client.above = false
    client.below = false
    client.ontop = false
    client.sticky = false
    client.maximized_horizontal = false
    client.maximized_vertical = false
  end

  if not rounded_corners then
    client.border_width, client.shape = 0, gshape.rectangle
    return
  end

  client.border_width = beautiful.border_width
  client.shape = function(cr, w, h)
    gshape.rounded_rect(cr, w, h, 8)
  end
end

local changesOnScreenPending = false

local function is_tag_maximized(tag)
  if not tag then return false end
  if tag.layout == awful.layout.suit.max then return true end
  if tag.layout == awful.layout.suit.max.fullscreen then return true end
end
local function changesOnScreen(currentScreen) ---@param currentScreen AwesomeScreenInstance
  local tag_is_max = is_tag_maximized(currentScreen.selected_tag)
  local managed_clients = {}
  for _, client in pairs(currentScreen.clients) do
    ---@diagnostic disable-next-line :undefined-field this is an injected field
    if not client.skip_decoration and not client.hidden and not quake:client_is_quake(client) then
      table.insert(managed_clients, client)
    end
  end

  local use_round_courners = (not tag_is_max and #managed_clients > 1)
  for _, client in pairs(managed_clients) do
    renderClient(client, client.fullscreen or use_round_courners)
  end
  changesOnScreenPending = false
end

local function clientCallback(client) ---@param client AwesomeClientInstance
  if changesOnScreenPending then return end
  if client.skip_decoration or not client.screen then return end ---@diagnostic disable-line :undefined-field this is an injected field
  changesOnScreenPending = true
  gtimer.delayed_call(bind.with_args(changesOnScreen, client.screen))
end
local function tagCallback(tag) ---@param tag AwesomeTagInstance
  if changesOnScreenPending then return end
  if not tag.screen then return end
  changesOnScreenPending = true
  gtimer.delayed_call(bind.with_args(changesOnScreen, tag.screen))
end

capi.client.connect_signal(compat.signal.manage, clientCallback)
capi.client.connect_signal(compat.signal.unmanage, clientCallback)
capi.client.connect_signal("property::hidden", clientCallback)
capi.client.connect_signal("property::minimized", clientCallback)
capi.client.connect_signal("property::fullscreen", clientCallback)

capi.tag.connect_signal("property::selected", tagCallback)
capi.tag.connect_signal("property::layout", tagCallback)
