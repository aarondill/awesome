--- This module implements dynamic client rendering
--- It currently only sets the border_width and corner rounding depending on the number of currently drawn clients.
--- Also handles hiding/showing the top bar

local alayout = require("awful.layout")
local beautiful = require("beautiful")
local capi = require("capi")
local gtimer = require("gears.timer")
local quake = require("module.quake")
local stream = require("stream")

local function shape_rounded_rect(cr, w, h) return require("gears.shape").rounded_rect(cr, w, h, 8) end
---@param client AwesomeClientInstance
---@param render_maximized boolean
local function renderClient(client, render_maximized)
  if quake.client_is_quake(client) then return end
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

---@type table<AwesomeScreenInstance, true>
local changesOnScreenPending = {}

local function is_tag_maximized(tag) ---@param tag AwesomeTagInstance?
  if not tag then return false end
  if tag.layout == alayout.suit.max then return true end
  if tag.layout == alayout.suit.max.fullscreen then return true end
end
local function changesOnScreen(currentScreen) ---@param currentScreen AwesomeScreenInstance
  if not currentScreen.valid then return end -- Check if the screen is still valid!
  ---@type AwesomeClientInstance[]
  local managed_clients = stream
    .new(currentScreen.clients)
    :filter(function(c) return c.valid end)
    :except(function(c) return c.skip_decoration or c.hidden end)
    :except(quake.client_is_quake)
    :toarray()

  local tag = currentScreen.selected_tag
  local tag_is_max = is_tag_maximized(tag)
  local render_maximized = tag_is_max or #managed_clients <= 1
  local show_top_bar = not tag_is_max or #managed_clients == 0 -- If the tag is maximized, don't show the top bar -- unless no clients.
  for _, client in ipairs(managed_clients) do
    local client_is_max = client.maximized_horizontal or client.maximized_vertical or client.maximized
    renderClient(client, client.fullscreen or client_is_max or render_maximized)
    if client.fullscreen then show_top_bar = false end -- If *any* client is fullscreen, the top panel should be hidden
  end

  local panel = currentScreen.top_panel
  if panel and not panel.user_set_hidden then --- Hide bars when app go fullscreen
    panel.visible = show_top_bar
  end
  local target_gap = tag_is_max and 0 or beautiful.useless_gap
  -- Set the gap to zero if maximized
  -- Only set the gap if it's different from the last calculated gap (to avoid undoing incgap/decgap)
  ---@class AwesomeTagInstance
  ---@field _auto_gap number? -- Injected field for this module
  if tag and (tag._auto_gap ~= target_gap) then
    tag.gap = target_gap
    tag._auto_gap = target_gap
  end
  changesOnScreenPending[currentScreen] = nil
end

local function clientCallback(client) ---@param client AwesomeClientInstance
  if client.skip_decoration then return end
  local s = client.screen
  if not s or changesOnScreenPending[s] then return end
  changesOnScreenPending[s] = true
  return gtimer.delayed_call(changesOnScreen, s)
end
local function tagCallback(tag) ---@param tag AwesomeTagInstance
  local s = tag.screen
  if not s or changesOnScreenPending[s] then return end
  changesOnScreenPending[s] = true
  return gtimer.delayed_call(changesOnScreen, s)
end

local compat = require("util.awesome.compat")
capi.client.connect_signal(compat.signal.manage, clientCallback)
capi.client.connect_signal(compat.signal.unmanage, clientCallback)
for _, p in ipairs({ "hidden", "minimized", "fullscreen", "maximized_horizontal", "maximized_vertical", "maximized" }) do
  capi.client.connect_signal("property::" .. p, clientCallback)
end
capi.client.connect_signal("tagged", clientCallback)

capi.tag.connect_signal("property::selected", tagCallback)
capi.tag.connect_signal("property::layout", tagCallback)
