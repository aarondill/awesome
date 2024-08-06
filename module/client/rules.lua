local require = require("util.rel_require")

local aclient = require("awful.client")
local aplacement = require("awful.placement")
local arules = require("awful.rules")
local ascreen = require("awful.screen")
local capi = require("capi")
local client_buttons = require(..., "buttons") ---@module "module.client.buttons"
local client_keys = require("configuration.keys.client")
local compat = require("util.awesome.compat")
local gshape = require("gears.shape")
local gtimer = require("gears.timer")
local quake = require("module.quake")
local stream = require("stream")

---@class AwesomeClientInstance
---@field skip_decoration boolean? Whether to skip decorating the client instance. This is an injected field!

---@alias AwesomeRule<T> { [string]: T }
---@class (exact) AwesomeRules
---@field rule? AwesomeRule<string>
---@field rule_any? AwesomeRule<string[]>
---@field except? AwesomeRule<string>
---@field except_any? AwesomeRule<string[]>
---@field properties? table
---@field callback? fun(c: AwesomeClientInstance): any

-- Rules
---@type AwesomeRules[]
local rules = {
  -- All clients will match this rule.
  {
    rule = {},
    except = { instance = quake.instance },
    properties = {
      focus = aclient.focus.filter,
      raise = true,
      screen = ascreen.preferred,
      placement = aplacement.no_overlap + aplacement.no_offscreen,
      floating = false,
      maximized = false,
      above = false,
      below = false,
      ontop = false,
      sticky = false,
      maximized_horizontal = false,
      maximized_vertical = false,
    },
    callback = function(c)
      if capi.awesome.startup then return end -- Not startup windows!
      if quake:client_is_quake(c) then return end -- Not the quake client
      -- Set the windows at the slave,
      -- i.e. put it at the end of others instead of setting it master.
      aclient.setslave(c)
    end,
  },
  -- All clients will match this rule.
  {
    rule = {},
    apply_on_restart = true,
    properties = {
      keys = client_keys,
      buttons = client_buttons,
      size_hints_honor = false, -- No minimum size, no offscreen windows
    },
    callback = function(c)
      if c.grant then -- Introduced in V5. Replaces awful.autofocus
        c:grant("autoactivate", "mouse_enter")
        c:grant("autoactivate", "history")
        c:grant("autoactivate", "switch_tag")
      end
    end,
  },
  --- Allow battle.net to just do whatever it wants
  {
    rule_any = { class = { "battle.net.exe" } },
    apply_on_restart = true,
    properties = {
      size_hints_honor = true,
    },
  },
  -- Enable titlebars on normal clients
  -- {
  -- 	rule_any = { type = { "normal", "dialog" } },
  -- 	callback = function(c)
  -- 		-- This *must* be set in a callback to preserve the property outside of the request::titlebars
  -- 		c.titlebars_enabled = true
  -- 	end,
  -- },
  {
    rule_any = { class = {
      "org.wezfurlong.wezterm",
      "XTerm",
      "kitty",
      "alacritty",
    } },
    properties = { opacity = 0.85 },
  },
  {
    -- Note: when using --app=%s, the role=browser is not applied, instead use the class
    rule_any = { role = { "browser" }, class = { "Vivaldi-stable" } },
    properties = { opacity = 0.90, maximized = false },
  },
  {
    rule_any = { class = { "ripdrag" } }, -- Make ripdrag follow the tag
    properties = { sticky = true },
  },
  {
    rule = { role = "pop-up", class = "Vivaldi-stable" },
    callback = function(c) ---@param c AwesomeClientInstance
      -- HACK: chromium doesn't respect the initial property when using '--app=%s'
      gtimer.start_new(0.2, function()
        if not c.valid then return false end
        c.maximized = false
        return false
      end)
    end,
  },
  -- Dialog clients should float and have rounded corners
  {
    rule_any = {
      type = { "dialog" },
      class = { "Wicd-client.py", "calendar.google.com", "ripdrag" },
      role = { "pop-up" },
    },
    -- This isn't really a pop-up
    except = { role = "pop-up", class = "Vivaldi-stable" },
    properties = {
      placement = aplacement.centered,
      ontop = true,
      floating = true,
      drawBackdrop = true,
      shape = compat.rules.shape_function(function(cr, w, h) return gshape.rounded_rect(cr, w, h, 8) end),
      skip_decoration = true,
    },
  },
}

local has_ruled, ruled = pcall(require, "ruled")
if has_ruled then
  ruled.client.append_rules(rules)
  capi.client.disconnect_signal(compat.signal.manage, ruled.client.apply)
  return capi.client.connect_signal(compat.signal.manage, function(c)
    if not capi.awesome.startup then return ruled.client.apply(c) end
    return stream.new(ruled.client.matching_rules(c)):foreach(function(rule)
      local props = rule.properties or {}
      if rule.apply_on_restart then return ruled.client.execute(c, props, { rule.callback }) end
      -- These will always be applied.
      local mini_properties = {
        buttons = props.buttons,
        keys = props.keys,
        size_hints_honor = props.size_hints_honor,
      }
      return ruled.client.execute(c, mini_properties, {})
    end)
  end)
  -- Stop here. Below is just awful.rules
end

arules.rules = rules
capi.client.disconnect_signal(compat.signal.manage, arules.apply)
return capi.client.connect_signal(compat.signal.manage, function(c)
  if not capi.awesome.startup then return arules.apply(c) end
  return stream.new(arules.matching_rules(c, arules.rules)):foreach(function(rule)
    local props = rule.properties or {}
    if rule.apply_on_restart then return arules.execute(c, props, { rule.callback }) end
    local mini_properties = { -- These will always be applied.
      buttons = props.buttons,
      keys = props.keys,
      size_hints_honor = props.size_hints_honor,
    }
    return arules.execute(c, mini_properties, {})
  end)
end)
