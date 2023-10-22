--- This module implements dynamic client rendering
--- It currently only sets the border_width and corner rounding depending on the number of currently drawn clients.

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
---@param corner boolean true means square, false means round
local function renderClient(client, corner)
  if quake:client_is_quake(client) then return end
  if client.skip_decoration then return end ---@diagnostic disable-line :undefined-field this is an injected field

  if client.rendering_mode == corner then return end -- Check cached.
  client.rendering_mode = corner ---@diagnostic disable-line :inject-field this is an injected field

  if corner then
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
    ---@diagnostic disable-next-line :undefined-field this is an injected field
    return c.valid and not c.skip_decoration and not c.hidden and not quake:client_is_quake(c)
  end)

  local square_corners = is_tag_maximized(currentScreen.selected_tag) or #managed_clients > 1
  for _, client in ipairs(managed_clients) do
    renderClient(client, client.fullscreen or square_corners)
  end
  changesOnScreenPending = false
end

local function clientCallback(client) ---@param client AwesomeClientInstance
  if changesOnScreenPending then return end
  if client.skip_decoration then return end ---@diagnostic disable-line :undefined-field this is an injected field
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

capi.tag.connect_signal("property::selected", tagCallback)
capi.tag.connect_signal("property::layout", tagCallback)
