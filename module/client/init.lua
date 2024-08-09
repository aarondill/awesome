local ewmh = require("awful.ewmh")
local require = require("util.rel_require")

require(..., "decoration") ---@module "module.client.decoration"
require(..., "rules") ---@module "module.client.rules"
require(..., "titlebar") ---@module "module.client.titlebar"

local function focus_handler(c) ---@param c AwesomeClientInstance
  if c.sticky then return false end
end
ewmh.add_activate_filter(focus_handler, "autofocus.check_focus")
ewmh.add_activate_filter(focus_handler, "autofocus.check_focus_tag")
ewmh.add_activate_filter(focus_handler, "mouse_enter")
