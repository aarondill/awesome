--Modified from: https://github.com/deficient/brightness
local abutton = require("awful.button")
local bind = require("util.bind")
local clickable_container = require("widget.material.clickable-container")
local get_child_by_id = require("util.get_child_by_id")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local list_directory = require("util.file.list_directory")
local notifs = require("util.notifs")
local read_async = require("util.file.read_async")
local wibox = require("wibox")
local write_async = require("util.file.write_async")

local bcontrol = {}

function bcontrol:new(args)
  return setmetatable({}, { __index = self }):init(args)
end

---Acts like assert, but the error is on the right level.
---@param bool boolean?
---@param msg string?
local function check(bool, msg)
  if not bool then return error(msg or "assertion failed.", 3) end
end
---@param val number
---@param min number
---@param max number
local function constrain(val, min, max) ---@return number
  return math.min(max, math.max(val, min))
end

---@class (exact) brightess_args
---@field step integer? the number of steps to change when clicking
---@field min integer? the minimum brightness value
---@field max integer? the maximum brightness value
---@field timeout integer? how often to update the brightness
---@field sysfs_bat_path string? the /sys/class/backlight/ folder containing the brightness information

---Create a new brightness control widget
---@param args brightess_args
---@return widget
function bcontrol:init(args)
  -- determine backend
  self.step = tonumber(args.step) or 5
  self.min = tonumber(args.min) or 1
  self.max = tonumber(args.max) or 100
  self.path = args.sysfs_bat_path
  check(not args.sysfs_bat_path or type(args.sysfs_bat_path) == "string", "sysfs_bat_path must be a string")
  check(self.min >= 0, "min must be >= 0")
  check(self.max <= 100, "max must be <= 100")
  check(self.step >= 0 and self.step <= 100, "step must be >= 0 and <= 100")

  self.widget = wibox.widget({
    { widget = wibox.widget.textbox, id = "textbox" },
    widget = clickable_container,
    buttons = gtable.join(
      abutton({}, 1, bind.with_args(self.up, self)), -- click
      abutton({}, 3, bind.with_args(self.down, self)), -- right
      abutton({}, 4, bind.with_args(self.up, self, 1)), -- scroll up
      abutton({}, 5, bind.with_args(self.down, self, 1)) -- scroll down
    ),
  })

  self.timer = gtimer.new({
    timeout = args.timeout or 3,
    callback = function()
      self:update()
    end,
    autostart = true,
    call_now = true,
  })
  if not self.path then
    local bat_dir = "/sys/class/backlight/"
    list_directory(bat_dir, { max = 1 }, function(names)
      if not names or not names[1] then return end
      local dir = bat_dir .. names[1]
      self.path = dir
      self:update()
    end)
  end

  self:set_text("???") -- Default to ??? brightness
  return self.widget
end

---@param value string|number
function bcontrol:set_text(value)
  if not value then return end
  value = tonumber(value) or "???"
  if type(value) == "number" then
    value = math.floor(0.5 + value) -- Round it if not an integer
  end
  local textbox = assert(get_child_by_id(self.widget, "textbox"), "Textbox is required")
  return textbox:set_text(string.format(" [%3s] ", value))
end

---@param callback brightness_callback?
function bcontrol:update(callback)
  return self:get(function(v)
    self:set_text(v)
    if callback then return callback(v) end
  end)
end

---@alias brightness_callback fun(brightness: integer)

---@param bright string|number
---@param max_bright string|number
---@param callback brightness_callback
local function calc_bright(bright, max_bright, callback)
  bright, max_bright = tonumber(bright) or 0, tonumber(max_bright) or 0
  if max_bright == 0 then return callback(0) end -- max brightness is 0. Give up.
  local percent = math.floor(bright / max_bright * 100 + 0.5)
  return callback(percent)
end

---@param callback fun(max_bright: integer)
function bcontrol:get_max_bright(callback)
  if self.max_bright then return callback(self.max_bright) end
  return read_async(self.path .. "/max_brightness", function(max_bright)
    self.max_bright = tonumber(max_bright) --- Cache this so I don't have to keep looking for it.
    return callback(self.max_bright)
  end)
end
---Get the current brightness
---@param callback brightness_callback This may never be called if path is not set.
function bcontrol:get(callback)
  if not self.path then return end
  return read_async(self.path .. "/brightness", function(bright)
    if not bright then return end
    return self:get_max_bright(function(max_bright)
      return calc_bright(bright, max_bright, callback)
    end)
  end)
end

---Set the current brightness
---@param brightness integer
---@param callback brightness_callback?
function bcontrol:set(brightness, callback)
  if not self.path then return end
  brightness = constrain(brightness, self.min, self.max)
  self:get_max_bright(function(max_bright)
    local brightness_val = math.floor((brightness / 100) * max_bright + 0.5)
    write_async(self.path .. "/brightness", tostring(brightness_val), function(err)
      if err then return notifs.critical(tostring(err)) end
      self:set_text(brightness)
      if callback then return callback(brightness) end
    end)
  end)
end

---Increase the current brightness
---@param step integer?
---@param callback brightness_callback?
function bcontrol:up(step, callback)
  local s = step or self.step
  return self:get(function(v)
    return self:set(v + s, callback)
  end)
end

---Decrease the current brightness
---@param step integer?
---@param callback brightness_callback?
function bcontrol:down(step, callback)
  local s = step or self.step
  return self:get(function(v)
    return self:set(v - s, callback)
  end)
end

return setmetatable(bcontrol, {
  __call = bcontrol.new,
})
