local alayout = require("awful.layout")
local ascreen = require("awful.screen")
local atag = require("awful.tag")
local capi = require("capi")
local gtable = require("gears.table")
local layouts = require("configuration.layouts")
local table_utils = require("util.tables")
local tags = require("configuration.tags")

if alayout.append_default_layouts then -- Added in v5
  capi.tag.connect_signal("request::default_layouts", function()
    return alayout.append_default_layouts(require("configuration.layouts"))
  end)
else -- v4. Breaks in v5
  alayout.layouts = require("configuration.layouts")
end

---@param tag tag_config
---@param s AwesomeScreenInstance
---@param i integer
local function resolve_tag(tag, s, i)
  if type(tag) == "table" then return tag end
  if type(tag) == "function" then return tag(s, i, tags) end -- Screen, index, array
  if type(tag) == "string" or type(tag) == "number" then return { name = tostring(tag) } end
  return {} -- Unknown tag -- empty properties
end
ascreen.connect_for_each_screen(function(s)
  return table_utils.foreach(tags, function(i, tag)
    if not tag then return end
    tag = resolve_tag(tag, s, i)
    local params = gtable.crush({
      name = i,
      layout = layouts[1] or alayout.suit.tile,
      gap_single_client = true,
      screen = s,
      selected = i == 1,
    }, tag)

    -- icon_only not specified, but icon is, and name isn't. Default to only icon.
    if tag.icon_only == nil and tag.icon and not tag.name then params.icon_only = true end

    return atag.add(params.name, params)
  end)
end)
