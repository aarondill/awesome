local require = require("util.rel_require")

local awful = require("awful")
local client_buttons = require(..., "buttons") ---@module "configuration.client.buttons"
local client_keys = require("configuration.keys.client")
local gshape = require("gears.shape")
-- Rules
local rules = {
  -- All clients will match this rule.
  {
    rule = {},
    properties = {
      focus = awful.client.focus.filter,
      raise = true,
      keys = client_keys,
      buttons = client_buttons,
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
else
  awful.rules.rules = rules
end
