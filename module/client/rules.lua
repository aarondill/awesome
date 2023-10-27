local require = require("util.rel_require")

local awful = require("awful")
local capi = require("capi")
local client_buttons = require(..., "buttons") ---@module "module.client.buttons"
local client_keys = require("configuration.keys.client")
local compat = require("util.compat")
local gshape = require("gears.shape")
local table_utils = require("util.table")
-- Rules
local rules = {
  -- All clients will match this rule.
  {
    rule = {},
    properties = {
      focus = awful.client.focus.filter,
      raise = true,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen,
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
      -- Set the windows at the slave,
      -- i.e. put it at the end of others instead of setting it master.
      if not capi.awesome.startup then awful.client.setslave(c) end
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
    properties = { opacity = 0.90 },
  },
  {
    rule_any = { class = { "ripdrag" } }, -- Make ripdrag follow the tag
    properties = { sticky = true },
  },
  -- Dialog clients should float and have rounded corners
  {
    rule_any = {
      type = { "dialog" },
      class = { "Wicd-client.py", "calendar.google.com", "ripdrag" },
      role = { "pop-up" },
    },
    properties = {
      placement = awful.placement.centered,
      ontop = true,
      floating = true,
      drawBackdrop = true,
      shape = function()
        return function(cr, w, h)
          gshape.rounded_rect(cr, w, h, 8)
        end
      end,
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
    return table_utils.foreach(ruled.client.matching_rules(c), function(_, rule)
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

awful.rules.rules = rules
capi.client.disconnect_signal(compat.signal.manage, awful.rules.apply)
return capi.client.connect_signal(compat.signal.manage, function(c)
  if not capi.awesome.startup then return awful.rules.apply(c) end
  return table_utils.foreach(awful.rules.matching_rules(c, awful.rules.rules), function(_, rule)
    if rule.apply_on_restart then return awful.rules.execute(c, rule.properties, { rule.callback }) end
    local mini_properties = { -- These will always be applied.
      buttons = rule.properties.buttons,
      keys = rule.properties.keys,
      size_hints_honor = rule.properties.size_hints_honor,
    }
    return awful.rules.execute(c, mini_properties, {})
  end)
end)
