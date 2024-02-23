--- Source: modified from `lain.util.quake`

local aclient = require("awful.client")
local bind = require("util.bind")
local capi = require("capi")
local compat = require("util.awesome.compat")
local gtable = require("gears.table")
local notifs = require("util.notifs")
local screen = require("util.types.screen")
local tables = require("util.tables")

-- Quake-like Dropdown application spawn
---@class QuakeTerminalWidget :QuakeConfig
local quake = {}
local function get_default_config()
  ---@class QuakeConfig
  local ret = {
    class = "QuakeDD", -- window name
    border = 1, -- client border width
    visible = false, -- initially not visible
    follow_screen = true, -- spawn on currently focused screen
    overlap = false, -- overlap wibox
    screen = screen.focused(), ---@type AwesomeScreenInstance?
    -- If width or height <= 1 this is a proportion of the workspace
    height = 0.5, -- height
    width = 1, -- width
    vert = "top", -- top, bottom or center
    horiz = "left", -- left, right or center
    ---@param self QuakeTerminalWidget
    ---@param c AwesomeClientInstance
    settings = function(self, c) end,
    spawn = function(class) ---@param class string
      return require("util.spawn").spawn({ "xterm", "-class", class })
    end,
  }
  return ret
end

quake.geometry = setmetatable({}, { __mode = "k" }) ---@type table<AwesomeScreenInstance, AwesomeGeometry>
---@param c AwesomeClientInstance
---Sets client to be a normal client
function quake:_disown(c)
  if c == self.client then self.client = nil end
  -- let's remove the sticky bit which may persist between awesome restarts.
  -- We don't close them as they may be valuable. They will just turn into
  -- normal clients.
  c.sticky = false
  c.ontop = false
  c.above = false
end
---@return AwesomeClientInstance? client
function quake:_get_client()
  if self.client and self.client.valid then return self.client end
  local iter = aclient.iterate(function(c) ---@param c AwesomeClientInstance
    return self:_client_is_self(c)
  end) ---@type fun():AwesomeClientInstance?
  -- First, we locate the client
  self.client = iter() -- consumes first item
  for other_c in iter do
    self:_disown(other_c)
  end
  return self.client
end
---@param s AwesomeScreenInstance?
---@return AwesomeScreenInstance?
function quake:_get_valid_screen(s)
  if s and s.valid then return s end
  if not self.follow_screen then -- we should stay on this screen, and it's already valid
    if self.screen and self.screen.valid then return self.screen end
  end
  -- Change to focused screen if necessary
  return screen.focused()
end
local pending_display = nil
---@param visible boolean|'toggle'?
---@param target_tag AwesomeTagInstance?
function quake:_display(visible, target_tag)
  self.screen = assert(self:_get_valid_screen(), "Can't display quake client without a valid screen!")
  if pending_display then -- we ignore the target_tag
    self.visible = true
    target_tag, pending_display = pending_display, nil
  else
    target_tag = target_tag or self.screen.selected_tag
    if type(visible) == "boolean" then -- given a value
      self.visible = visible
    elseif visible == "toggle" then -- we're already visible, so check if we're going to a different tag
      if not self.visible then
        self.visible = true -- if not visible, we should *always* become visible
      elseif self.last_tag then -- already visible, so if we're changing tags, stay visible, else hide
        self.visible = target_tag ~= self.last_tag
      else -- We're somehow visible, but we don't have a last tag. just hide and hope it fixes itself
        self.visible = false
      end
    end
  end

  if self.visible and not target_tag then
    return notifs.warn("Can't display quake client without a selected tag!") and nil
  end

  local c = self:_get_client()
  if not c then
    -- No client, but we aren't supposed to display, so it's fine
    if not self.visible then return end
    pending_display = target_tag -- save the tag to display so we can restore it after spawn finishes
    self.spawn(self.class) -- Spawn the client, _managed will call us later so we can display it
    return
  end

  -- Set geometry
  c.floating = true
  c.border_width = self.border
  c.size_hints_honor = false
  c:geometry(self:_compute_size(self.screen))

  -- Set not sticky and on top
  c.sticky = false
  c.ontop = true
  c.above = true
  c.skip_taskbar = true

  self:settings(c) -- Additional user settings

  if self.visible then -- Toggle display
    self.last_tag = target_tag
    c.maximized, c.fullscreen = self.maximized, self.fullscreen
    c.hidden, c.focusable = false, true
    c:raise()
    c:tags({ target_tag })
    capi.client.focus = c
  else
    self.maximized, self.fullscreen = c.maximized, c.fullscreen
    c.maximized, c.fullscreen, c.focusable = false, false, false
    c.hidden = true
    c:tags({}) -- remove from all tags
  end
end

---@param s AwesomeScreenInstance
---@return AwesomeGeometry?
function quake:_compute_size(s)
  if not s then return end
  -- skip if we already have a geometry for this screen
  if self.geometry[s] then return self.geometry[s] end
  local geom = self.overlap and s.geometry or s.workarea
  local width, height = self.width, self.height
  if width <= 1 then width = math.floor(geom.width * width) - 2 * self.border end
  if height <= 1 then height = math.floor(geom.height * height) end
  local x, y ---@type number, number
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
  self.geometry[s] = { x = x, y = y, width = width, height = height }
  return self.geometry[s]
end

function quake:_client_is_self(c) ---@param c AwesomeClientInstance
  return c.instance == self.class
end
function quake:_managed(c) ---@param c AwesomeClientInstance
  if not self:_client_is_self(c) then return end
  if self.client then
    local msg =
      "A second quake client has been detected. This is not allowed! Don't spawn multiple clients with the same class."
    notifs.warn(msg)
    self:_disown(self.client)
  end
  self.client = c
  self:_display()
end
function quake:_unmanaged(c) ---@param c AwesomeClientInstance
  if not self:_client_is_self(c) then return end
  self.client = nil
  self.visible = false
end

--------------------------------------------------------------------------------------------
-------------------------------- Public interface functions --------------------------------
--------------------------------------------------------------------------------------------

---Kill the current quake client
---@return boolean success false if no client exists
function quake:kill()
  local c = self:_get_client()
  if c then c:kill() end
  return c ~= nil
end

---Hide the quake application
function quake:hide() return self:_display(false) end
---Show the quake application
---@param tag AwesomeTagInstance? the tag to show on (optional: current)
function quake:show(tag) return self:_display(true, tag) end
---Toggle the quake application
---@param tag AwesomeTagInstance? the tag to show on (optional: current). Only used when showing
function quake:toggle(tag) return self:_display("toggle", tag) end
---@param conf QuakeConfig
function quake.new(conf)
  local self = tables.clone(quake, true)
  gtable.crush(self, get_default_config(), true) -- Override defaults using conf
  gtable.crush(self, conf, true) -- Override defaults using conf
  self.maximized, self.fullscreen = false, false
  capi.client.connect_signal(compat.signal.manage, bind(self._managed, self))
  capi.client.connect_signal(compat.signal.unmanage, bind(self._unmanaged, self))
  -- Handle initial self.visible
  if self.visible then self:_display() end
  return self
end

return setmetatable(quake, {
  __call = function(_, ...) return quake.new(...) end,
})
