local require = require("util.rel_require")

local mat_icon = require("widget.material.icon")
local name = require(..., "name") ---@module "widget.distro.name"
local path = require("util.path")
local unzip = require(..., "icons") ---@module "widget.distro.icons"
local wibox = require("wibox")

local distro_name ---@type string?
local function new()
  distro_name = distro_name or name.get_os_name() -- Globally cache this!
  local w = wibox.widget({ render_empty = false, widget = mat_icon })
  unzip.unzip_icons(function(dir)
    w.icon = path.join(dir, distro_name .. ".png")
  end)
  return w
end
return new
