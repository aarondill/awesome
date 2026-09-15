local require = require("util.rel_require")
local tables = require("util.tables")

local aclient = require("awful.client")
local aplacement = require("awful.placement")
local arules = require("awful.rules")
local ascreen = require("awful.screen")
local capi = require("capi")
local client_config = require("configuration.keys.client")
local compat = require("util.awesome.compat")
local gshape = require("gears.shape")
local gtimer = require("gears.timer")
local quake = require("module.quake")
local stream = require("stream")
local client_buttons, client_keys = client_config.buttons, client_config.keys

---@class AwesomeClientInstance
---@field skip_decoration boolean? Whether to skip decorating the client instance. This is an injected field!
---@field titlebars_enabled boolean? Injected field

---@alias AwesomeRule<T> { [string]: T }
---@class (exact) AwesomeRules
---@field rule? AwesomeRule<unknown>
---@field rule_any? AwesomeRule<unknown[]>
---@field except? AwesomeRule<unknown>
---@field except_any? AwesomeRule<unknown[]>
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
      if quake.client_is_quake(c) then return end -- Not the quake client
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
    properties = { opacity = 0.95 },
  },
  {
    -- Note: when using --app=%s, the role=browser is not applied, instead use the class
    rule_any = { role = { "browser" }, class = { "Vivaldi-stable" } },
    properties = { opacity = 0.95, maximized = false },
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
  {
    rule = { class = "Mars" },
    callback = function(c) ---@param c AwesomeClientInstance
      -- HACK: Mars automatically maximizes itself
      gtimer.start_new(0.2, function()
        if c.valid then c.maximized = false end
        return false
      end)
    end,
  },
  -- Dialog clients should float and have rounded corners
  {
    rule_any = {
      type = { "dialog", "splash" },
      class = { "Wicd-client.py", "ripdrag" },
      role = { "pop-up" },
      modal = { true },
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

  --- Floating calculator
  {
    rule = { class = "gnome-calculator" },
    callback = function(c)
      if not c.valid then return true end
      local has_other = stream
        .new(capi.client.get(c.screen))
        :filter(function(c2) return c2.class == c.class and c2.window ~= c.window end)
        :anymatch(function(c2) ---@param c2 AwesomeClientInstance
          return stream.new(c:tags()):anymatch(function(t) return tables.contains(c2:tags(), t) end)
        end)
      -- If there is already another calculator open on this tag&screen, don't move it
      if has_other then return true end

      --- HACK: We want to set the window to the minimum size in the hints, but
      --- size_hints may not be ready yet, so we may need to wait for it to be set.
      local set_size
      function set_size()
        local w, h = c.size_hints.min_width, c.size_hints.min_height
        if w and h then
          c:disconnect_signal("property::size_hints", set_size)
          c:geometry({ width = w, height = h })
        end
        -- Set these properties even if not ready so that the window doesn't move as much
        c.floating, c.ontop = true, true
        aplacement.top_right(c, {
          honor_padding = true,
          honor_workarea = true,
        })
        capi.client.focus = c
      end
      c:connect_signal("property::size_hints", set_size)
      set_size()
    end,
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
return capi.client.connect_signal(compat.signal.manage, function(c) ---@param c AwesomeClientInstance
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
