--- Source: modified from `lain.util.quake`

local awful = require("awful")
local bind = require("util.bind")
local capi = require("capi")
local compat = require("util.compat")
local gtable = require("gears.table")

-- Quake-like Dropdown application spawn
local quake = {}

function quake:_display(visible)
  if visible ~= nil then self.visible = visible end
  if self.followtag then self.screen = awful.screen.focused() end
  local class_match = function(c)
    -- c.name may be changed!
    return c.instance == self.class
  end
  local iter = awful.client.iterate(class_match)
  -- First, we locate the client
  local c = iter() -- consumes first item
  for other_c in iter do
    -- Additional matching clients, let's remove the sticky bit
    -- which may persist between awesome restarts. We don't close
    -- them as they may be valuable. They will just turn into
    -- normal clients.
    other_c.sticky = false
    other_c.ontop = false
    other_c.above = false
  end

  if not c then
    if not self.visible then return end
    -- The client does not exist, we spawn it
    return self.spawn(self.class)
  end

  -- Set geometry
  c.floating = true
  c.border_width = self.border
  c.size_hints_honor = false
  c:geometry(self.geometry[self.screen.index] or self:_compute_size())

  -- Set not sticky and on top
  c.sticky = false
  c.ontop = true
  c.above = true
  c.skip_taskbar = true

  -- Additional user settings
  if self.settings then self.settings(c) end

  if self.visible then -- Toggle display
    self:_show(c)
  else
    self:_hide(c)
  end

  return c
end
function quake:_hide(c)
  local maximized = c.maximized
  local fullscreen = c.fullscreen
  self.maximized = maximized
  self.fullscreen = fullscreen
  c.maximized = false
  c.fullscreen = false
  c.hidden = true
  local ctags = c:tags()
  for j, _ in pairs(ctags) do
    ctags[j] = nil
  end
  c:tags(ctags)
end

function quake:_show(c)
  c.hidden = false
  c.maximized = self.maximized
  c.fullscreen = self.fullscreen
  c:raise()
  self.last_tag = self.screen.selected_tag
  c:tags({ self.screen.selected_tag })
  capi.client.focus = c
end

function quake:_compute_size()
  -- skip if we already have a geometry for this screen
  if self.geometry[self.screen.index] then return self.geometry[self.screen.index] end
  local s = capi.screen[self.screen.index]
  local geom = self.overlap and s.geometry or s.workarea
  local width, height = self.width, self.height
  if width <= 1 then width = math.floor(geom.width * width) - 2 * self.border end
  if height <= 1 then height = math.floor(geom.height * height) end
  local x, y
  if self.horiz == "left" then
    x = geom.x
  elseif self.horiz == "right" then
    x = geom.width + geom.x - width
  else
    x = geom.x + (geom.width - width) / 2
  end
  if self.vert == "top" then
    y = geom.y
  elseif self.vert == "bottom" then
    y = geom.height + geom.y - height
  else
    y = geom.y + (geom.height - height) / 2
  end
  self.geometry[self.screen.index] = { x = x, y = y, width = width, height = height }
  return self.geometry[self.screen.index]
end

---Hide the quake application
function quake:hide()
  self:_display(false)
end
function quake:_on_tag(tag)
  if self.followtag then self.screen = awful.screen.focused() end
  tag = tag or self.screen.selected_tag
  return not tag or self.last_tag == tag
end
---Show the quake application
---@param tag table? the tag to show on (optional: current)
function quake:show(tag)
  tag = tag or self.screen.selected_tag
  local on_tag = self:_on_tag(tag) -- changes self.screen. Call it before.
  local c = self:_display(true)
  if c and not on_tag then c:move_to_tag(tag) end
end
---Toggle the quake application
---@param tag table? the tag to show on (optional: current). Only used when showing
function quake:toggle(tag)
  if not self:_on_tag(tag) or not self.visible then
    self:show()
  else
    self:hide()
  end
end

function quake:_client_is_self(c)
  return c.instance == self.class and c.screen == self.screen
end
function quake:_managed(c)
  if not self:_client_is_self(c) then return end
  self:_display()
end
function quake:_unmanaged(c)
  if not self:_client_is_self(c) then return end
  self.visible = false
end
quake.defaults = {
  -- spawn application
  spawn = function(class)
    return "xterm -class" .. class
  end,
  class = "QuakeDD", -- window name
  border = 1, -- client border width
  visible = false, -- initially not visible
  followtag = true, -- spawn on currently focused screen
  overlap = false, -- overlap wibox
  screen = awful.screen.focused(),
  -- If width or height <= 1 this is a proportion of the workspace
  height = 0.5, -- height
  width = 1, -- width
  vert = "top", -- top, bottom or center
  horiz = "left", -- left, right or center
}
function quake.new(conf)
  local defaults = gtable.clone(quake.defaults, false)
  local self = gtable.crush(defaults, conf or {}, true)
  self = gtable.crush(self, quake, true)
  self.geometry = {} -- internal use
  self.maximized = false
  self.fullscreen = false

  capi.client.connect_signal(compat.signal.manage, bind(self._managed, self))
  capi.client.connect_signal(compat.signal.unmanage, bind(self._unmanaged, self))

  self:_display() -- Handle initial self.visible

  return self
end

return setmetatable(quake, {
  __call = function(_, ...)
    return quake.new(...)
  end,
})
