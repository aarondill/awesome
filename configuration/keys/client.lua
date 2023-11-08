local require = require("util.rel_require")

local aclient = require("awful.client")
local akey = require("awful.key")
local atitlebar = require("awful.titlebar")
local gtable = require("gears.table")
local mod = require(..., "mod") ---@module "configuration.keys.mod"
local modkey = mod.modKey
-- Key bindings
local clientkeys = gtable.join(
  akey({ modkey }, "f", function(c)
    c.fullscreen = not c.fullscreen
    c:raise()
  end, { description = "toggle fullscreen", group = "client" }),

  akey({ modkey }, "q", function(c)
    c:kill()
  end, { description = "close", group = "client" }),

  akey({ modkey, "Control" }, "s", function(c)
    c.sticky = not c.sticky
  end, { description = "toggle sticky", group = "client" }),
  akey({ modkey, "Control" }, "space", aclient.floating.toggle, { description = "toggle floating", group = "client" }),
  akey({ modkey, "Shift" }, "Return", function(c)
    c:swap(aclient.getmaster())
  end, { description = "move to master", group = "client" }),

  -- akey({ modkey }, "o", function(c)
  -- 	c:move_to_screen()
  -- end, { description = "move window to next screen", group = "client" }),

  akey({ modkey }, "o", function(c)
    c.opacity = c.opacity + 0.1
  end, { description = "Increase opacity", group = "client" }),
  akey({ modkey, "Shift" }, "o", function(c)
    c.opacity = math.max(c.opacity - 0.1, 0.2)
  end, { description = "Decrease opacity", group = "client" }),

  akey({ modkey }, "t", function(c)
    c.ontop = not c.ontop
  end, { description = "toggle keep on top", group = "client" }),
  akey({ modkey }, "n", function(c)
    -- The client currently has the input focus, so it cannot be
    -- minimized, since minimized clients can't have the focus.
    c.minimized = true
  end, { description = "minimize", group = "client" }),
  akey({ modkey }, "m", function(c)
    c.maximized = not c.maximized
    c:raise()
  end, { description = "(un)maximize", group = "client" }),
  akey({ modkey, "Control" }, "m", function(c)
    c.maximized_vertical = not c.maximized_vertical
    c:raise()
  end, { description = "(un)maximize vertically", group = "client" }),
  akey({ modkey, "Shift" }, "m", function(c)
    c.maximized_horizontal = not c.maximized_horizontal
    c:raise()
  end, { description = "(un)maximize horizontally", group = "client" }),

  akey({ modkey }, "`", function(c)
    atitlebar.toggle(c, "top")
  end, { description = "toggle top titlebar", group = "client" })
)
return clientkeys
