local require = require("util.rel_require")

local aclient = require("awful.client")
local atitlebar = require("awful.titlebar")
local awful_key = require("awful.key")
local gtable = require("gears.table")
local mod = require(..., "mod") ---@module "configuration.keys.mod"
local modkey = mod.modKey
---A typed helper around awful_key.new -- Note: specific to this file
---@alias aKeyDataTable {description: string, group: string}
---@param modKeys string[]
---@param key string
---@param press? fun(c: AwesomeClientInstance): any
---@param release? (fun(c: AwesomeClientInstance): any)|aKeyDataTable
---@param data? aKeyDataTable
local ckey = function(modKeys, key, press, release, data) return awful_key.new(modKeys, key, press, release, data) end

-- Key bindings
local clientkeys = gtable.join(
  ckey({ modkey }, "f", function(c)
    c.fullscreen = not c.fullscreen
    c:raise()
  end, { description = "toggle fullscreen", group = "client" }),

  ckey({ modkey }, "q", function(c) c:kill() end, { description = "close", group = "client" }),

  ckey(
    { modkey, "Control" },
    "s",
    function(c) c.sticky = not c.sticky end,
    { description = "toggle sticky", group = "client" }
  ),
  ckey({ modkey, "Control" }, "space", aclient.floating.toggle, { description = "toggle floating", group = "client" }),
  ckey({ modkey, "Shift" }, "Return", function(c)
    local master = aclient.getmaster() ---@type AwesomeClientInstance?
    if master then return c:swap(master) end
  end, { description = "move to master", group = "client" }),

  ckey(
    { modkey, "Shift", "Control" },
    "k",
    function(c) c:move_to_screen() end,
    { description = "move window to next screen", group = "client" }
  ),
  ckey({ modkey, "Shift", "Control" }, "j", function(c)
    local s = c.screen and c.screen.index - 1 -- Might be nil, thus +1, but there's a bigger problem here
    c:move_to_screen(s)
  end, { description = "move window to prev screen", group = "client" }),

  ckey(
    { modkey },
    "o",
    function(c) c.opacity = math.min(c.opacity + 0.1, 1) end,
    { description = "Increase opacity", group = "client" }
  ),
  ckey(
    { modkey, "Shift" },
    "o",
    function(c) c.opacity = math.max(c.opacity - 0.1, 0.2) end,
    { description = "Decrease opacity", group = "client" }
  ),

  ckey({ modkey }, "t", function(c) c.ontop = not c.ontop end, { description = "toggle keep on top", group = "client" }),
  ckey({ modkey }, "n", function(c)
    -- The client currently has the input focus, so it cannot be
    -- minimized, since minimized clients can't have the focus.
    c.minimized = true
  end, { description = "minimize", group = "client" }),
  ckey({ modkey }, "m", function(c)
    c.maximized = not c.maximized
    c:raise()
  end, { description = "(un)maximize", group = "client" }),
  ckey({ modkey, "Control" }, "m", function(c)
    c.maximized_vertical = not c.maximized_vertical
    c:raise()
  end, { description = "(un)maximize vertically", group = "client" }),
  ckey({ modkey, "Shift" }, "m", function(c)
    c.maximized_horizontal = not c.maximized_horizontal
    c:raise()
  end, { description = "(un)maximize horizontally", group = "client" }),

  ckey(
    { modkey },
    "`",
    function(c) atitlebar.toggle(c, "top") end,
    { description = "toggle top titlebar", group = "client" }
  )
)
return clientkeys
