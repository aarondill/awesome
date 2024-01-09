local quake = require("module.quake")
local require = require("util.rel_require")

local aclient = require("awful.client")
local aplacement = require("awful.placement")
local arules = require("awful.rules")
local ascreen = require("awful.screen")
local capi = require("capi")
local client_buttons = require(..., "buttons") ---@module "module.client.buttons"
local client_keys = require("configuration.keys.client")
local compat = require("util.compat")
local gshape = require("gears.shape")
local gtimer = require("gears.timer")
local table_utils = require("util.tables")

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
  -- Enable titlebars on normal clients
  -- {
  -- 	rule_any = { type = { "normal", "dialog" } },
  -- 	callback = function(c)
  -- 		-- This *must* be set in a callback to preserve the property outside of the request::titlebars
  -- 		c.titlebars_enabled = true
  -- 	end,
  -- },
  {
    rule_any = { role = { "browser" } },
    properties = { opacity = 0.90, maximized = false },
  },
  {
    rule_any = { class = { "ripdrag" } }, -- Make ripdrag follow the tag
    properties = { sticky = true },
  },
  {
    rule_any = { instance = { "fslite.vercel.app" } },
    callback = function(c) ---@param c AwesomeClientInstance
      -- HACK: chromium doesn't respect the initial property when using '--app=%s'
      gtimer.start_new(0.09, function()
        if not c.valid then return end
        c.maximized = false
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
    except_any = { instance = { "fslite.vercel.app" } },
    properties = {
      placement = aplacement.centered,
      ontop = true,
      floating = true,
      drawBackdrop = true,
      shape = compat.rules.shape_function(function(cr, w, h)
        return gshape.rounded_rect(cr, w, h, 8)
      end),
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
    return table_utils.foreach(ruled.client.matching_rules(c), function(rule)
      if rule.apply_on_restart then return ruled.client.execute(c, rule.properties, { rule.callback }) end
      local mini_properties = { -- These will always be applied.
        buttons = rule.properties.buttons,
        keys = rule.properties.keys,
        size_hints_honor = rule.properties.size_hints_honor,
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
  return table_utils.foreach(arules.matching_rules(c, arules.rules), function(rule)
    if rule.apply_on_restart then return arules.execute(c, rule.properties, { rule.callback }) end
    local mini_properties = { -- These will always be applied.
      buttons = rule.properties.buttons,
      keys = rule.properties.keys,
      size_hints_honor = rule.properties.size_hints_honor,
    }
    return arules.execute(c, mini_properties, {})
  end)
end)
