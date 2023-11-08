---From https://github.com/Amitabha37377/Awful-DOTS/blob/master/awesome/fancy_taglist.lua

-- awesomewm fancy_taglist: a taglist that contains a tasklist for each tag.
-- Usage (add s.mytaglist to the wibar):
-- awful.screen.connect_for_each_screen(function(s)
--     ...
--     local fancy_taglist = require("fancy_taglist")
--     s.mytaglist = fancy_taglist.new({
--         screen = s,
--         taglist = { buttons = mytagbuttons },
--         tasklist = { buttons = mytasklistbuttons }
--     })
--     ...
-- end)
--
-- If you want rounded corners, try this in your theme:
-- theme.taglist_shape = function(cr, w, h)
--     return gears.shape.rounded_rect(cr, w, h, theme.border_radius)
-- end
local capi = require("capi")
local compat = require("util.compat")
local require = require("util.rel_require")

local ascreen = require("awful.screen")
local awidget = require("awful.widget")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local wibox = require("wibox")
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require("widget.material.clickable-container")

local box_height = dpi(5) -- Tag height
local box_width = dpi(5) -- Tag width
local icon_size = dpi(20) -- Size of icons
local internal_spacing = dpi(3) -- Between tagname and client icons
---@class FancyTaglistOptions
---@field screen? screen
---@field tasklist? table -> see awful.widget.tasklist
---@field taglist? table  -> see awful.widget.taglist

local function box_margins(widget)
  return {
    { widget, widget = wibox.container.place },
    top = box_height,
    bottom = box_height,
    left = box_width,
    right = box_width,
    widget = wibox.container.margin,
  }
end

local function constrain_icon(widget)
  return {
    {
      widget,
      height = icon_size,
      strategy = "exact",
      widget = wibox.container.constraint,
    },
    widget = wibox.container.place,
  }
end

local function fancy_tasklist(cfg, tag)
  local MAX_ICONS = 5
  local function only_this_tag(c) ---@param c AwesomeClientInstance
    return gtable.hasitem(c:tags(), tag)
  end
  local c = gtable.join(cfg, {
    filter = function()
      return true -- Truth filter. The filter is called in source (to ensure that we don't get too many clients)
    end,
    source = function()
      local clients = {}
      for _, c in ipairs(capi.client.get()) do
        if #clients < MAX_ICONS and only_this_tag(c) then -- MAX_ICONS and check filter
          table.insert(clients, c)
        end
      end
      return clients
    end,
    layout = {
      spacing = beautiful.taglist_spacing,
      layout = wibox.layout.fixed.horizontal,
    },
    widget_template = {
      id = "clienticon",
      widget = awidget.clienticon,
      create_callback = function(self, c, _, _)
        self:get_children_by_id("clienticon")[1].client = c
      end,
    },
  })
  return awidget.tasklist(c)
end

local module = {}

local this_path = ...

local function update_callback(self, tag, _, _)
  -- make sure that empty tasklists take up no extra space
  local list_separator = self:get_children_by_id("list_separator")[1]
  if not list_separator then return end
  if #tag:clients() == 0 then return list_separator:set_spacing(0) end
  return list_separator:set_spacing(internal_spacing)
end

---@param cfg FancyTaglistOptions?
function module.new(cfg)
  cfg = cfg or {}
  local taglist_cfg = cfg.taglist or {}
  local tasklist_cfg = cfg.tasklist or {}
  --- Set default buttons
  taglist_cfg.buttons = taglist_cfg.buttons or require(this_path, "buttons")

  local screen = cfg.screen or ascreen.focused()
  taglist_cfg.screen, tasklist_cfg.screen = screen, screen

  local overrides = {
    filter = awidget.taglist.filter.all,
    widget_template = {
      {
        box_margins({
          { -- tag
            id = "text_role",
            widget = wibox.widget.textbox,
            [compat.widget.halign] = "center",
          },
          constrain_icon({ -- tasklist
            id = "tasklist_placeholder",
            layout = wibox.layout.fixed.horizontal,
          }),
          id = "list_separator",
          spacing = internal_spacing,
          layout = wibox.layout.fixed.horizontal,
        }),
        widget = clickable_container,
      },
      id = "background_role",
      widget = wibox.container.background,
      create_callback = function(self, tag, _index, _tags)
        local tasklist = fancy_tasklist(tasklist_cfg, tag)
        self:get_children_by_id("tasklist_placeholder")[1]:add(tasklist)
        return update_callback(self, tag, _index, _tags)
      end,
      update_callback = update_callback,
    },
  }
  return awidget.taglist(gtable.join(taglist_cfg, overrides))
end

return module
