local awful = require("awful")
local beautiful = require("beautiful")
local bind = require("util.bind")
local concat_command = require("util.concat_command")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local spawn = require("util.spawn")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi

---@class MediaControl.args
local defaults = {
  ---Icon to show when media is playing
  play_icon = beautiful.play, ---@type string?
  ---Icon to show when media is paused
  pause_icon = beautiful.pause, ---@type string?
  ---Icon to show when media is stopped (no media)
  stop_icon = beautiful.stop, ---@type string?
  ---Whether to hide the widget when no media is playing
  autohide = true,
  ---How often to update the widget
  ---Higher refresh_rate == less CPU requirements
  ---Lower refresh_rate == better Widget response time
  refresh_rate = 10,
  ---The MPRIS name of the player to search for (playerctl -p NAME), empty for first available player
  name = "",
  ---The format to set the widget text to. {text} escapes are recogized
  --- Accepted properties are the values of MediaControl.info. If a property is not defined, it will not be changed (ie, '{not-exist}' expands to '{not-exist}').
  format = "{artist} | {title}",
  ---The maximum width of the widget text (px). Set to 0 for no limit.
  max_width = dpi(70),
  ---Speed to scroll the widget text.
  scroll_speed = 20,
  ---The fps to render the scrolling widget at
  fps = 15,
  ---Number of seconds between song changes while scrolling (ignores inputs between).
  debounce = 1, ---@type number
}

---@class MediaControl :MediaControl.args
local MediaControl = {}

---@param args MediaControl.args?
function MediaControl:new(args)
  return setmetatable({}, { __index = self }):init(args)
end

---@param args MediaControl.args?
---@return MediaControl
function MediaControl:init(args)
  gtable.crush(self, defaults, true) -- Set default
  if args then gtable.crush(self, args or {}, true) end -- Set any user overrides

  local widget_template = {
    layout = wibox.layout.fixed.horizontal,
    { id = "icon", widget = wibox.widget.imagebox },
    {
      layout = wibox.container.scroll.horizontal,
      step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
      max_size = self.max_width ~= 0 and self.max_width or nil,
      speed = self.scroll_speed,
      fps = self.fps,
      { id = "current_song", widget = wibox.widget.textbox },
    },
  }
  self.widget = wibox.widget(widget_template)
  self.widget.tooltip = awful.tooltip({
    objects = { self.widget },
    mode = "outside",
    align = "bottom",
    delay_show = 1,
  })
  function self.widget:set_status(image)
    self:get_children_by_id("icon")[1].image = image
  end
  function self.widget:set_text(text)
    self:get_children_by_id("current_song")[1].text = text
    self.tooltip:set_text(text)
  end

  self:watch(self.refresh_rate)

  local update_widget = bind(self.update_widget, self)
  self.widget:buttons(gtable.join(
    -- button 1: left click  - play/pause
    awful.button({}, 1, bind(self.PlayPause, self, update_widget)),
    -- button 4: scroll up - previous song
    awful.button({}, 4, bind(self.debounce_song_changes, self, self.Previous, self, update_widget)),
    -- button 5: scroll down   - next song
    awful.button({}, 5, bind(self.debounce_song_changes, self, self.Next, self, update_widget))
  ))

  return self.widget
end

function MediaControl:debounce_song_changes(cb, ...)
  local should_call = (not self._last_change_time) or (os.difftime(os.time(), self._last_change_time) > self.debounce)
  self._last_change_time = os.time() -- update regardless
  if should_call then return cb(...) end
end

---@param status string?
function MediaControl:update_widget_icon(status)
  status = status and string.gsub(status, "\n", "")
  local icon = self.stop_icon -- default to stop
  if status == "Playing" then
    icon = self.pause_icon
  elseif status == "Paused" then
    icon = self.play_icon
  elseif status == "Stopped" then
    icon = self.stop_icon
  end
  self.widget:set_status(icon)
end

---@param text string
function MediaControl:update_widget_text(text)
  self.widget:set_text(text)
  self.widget:set_visible(true)
end

function MediaControl:hide_widget()
  self.widget:set_text("Offline")
  self.widget:set_status(self.stop_icon)
  self.widget:set_visible(not self.autohide)
end

---@private
---@param cmd string[]
---@return string[]
function MediaControl:handle_name(cmd)
  if self.name and #self.name > 0 then
    local cmd_new = concat_command(cmd, { "--player", self.name })
    ---@cast cmd_new string[] this is fine
    return cmd_new
  else
    return cmd
  end
end
local function handle_exit_callback(cb, reason, code)
  return cb(reason == "exit" and code == 0)
end
---@param cb fun(success: boolean)
function MediaControl:PlayPause(cb)
  spawn.spawn(self:handle_name({ "playerctl", "play-pause" }), {
    exit_callback = bind(handle_exit_callback, cb),
  })
end
---@param cb fun(success: boolean)
function MediaControl:Previous(cb)
  spawn.spawn(self:handle_name({ "playerctl", "previous" }), {
    exit_callback = bind(handle_exit_callback, cb),
  })
end
---@param cb fun(success: boolean)
function MediaControl:Next(cb)
  spawn.spawn(self:handle_name({ "playerctl", "next" }), {
    exit_callback = bind(handle_exit_callback, cb),
  })
end

---Get info about the media source
---@param cb fun(info: MediaControl.info?)
function MediaControl:info(cb)
  -- Some of these are unneeded, but we gather them for the sake of the user's format string
  local variables = {
    "album",
    "albumArtist",
    "artUrl",
    "artist",
    "length",
    "playerName",
    "status",
    "title",
    "url",
    "volume",
  }
  local cmd
  do
    local format_stats = {}
    for _, v in ipairs(variables) do
      table.insert(format_stats, "{{" .. v .. "}}")
    end
    cmd = self:handle_name({
      "playerctl",
      "metadata",
      "--format",
      table.concat(format_stats, "\n"),
    })
  end
  spawn.async(cmd, function(stdout, _, exit_reason, exit_code)
    if exit_reason ~= "exit" or exit_code ~= 0 then return cb(nil) end
    ---@class MediaControl.info
    local info = {
      album = nil,
      albumArtist = nil,
      artUrl = nil,
      artist = nil,
      length = nil,
      playerName = nil,
      status = nil,
      title = nil,
      url = nil,
      volume = nil,
    }

    -- mpris:trackid
    -- mpris:length
    -- mpris:artUrl
    -- xesam:album
    -- xesam:albumArtist
    -- xesam:artist
    -- xesam:autoRating
    -- xesam:discNumber
    -- xesam:title
    -- xesam:trackNumber
    -- xesam:url
    local i = 1
    for line in stdout:gmatch("([^\n]*)\n?") do -- Order is defined by variables[]
      local prop = variables[i]
      if #line == 0 then -- Empty lines
        -- Transform camel case to lower case words -- albumArtist -> album artist
        -- Source: https://love2d.org/forums/viewtopic.php?t=81128
        line = "Unknown " .. prop:gsub(".%f[%l]", " %1"):gsub("%l%f[%u]", "%1 "):lower()
      end
      info[prop] = line
      i = i + 1
    end
    cb(info)
  end)
end

function MediaControl:update_widget()
  self:info(function(info)
    -- Status unavailable? Media Player isn't active, hide the widget
    if not info or not info.status then return self:hide_widget() end
    self:update_widget_icon(info.status)
    local str = string.gsub(self.format, "{([^}]*)}", info)
    self:update_widget_text(str)
  end)
end

function MediaControl:watch(refresh_rate)
  gtimer.new({
    timeout = refresh_rate,
    callback = bind(self.update_widget, self),
    autostart = true,
    call_now = true,
  })
end

return setmetatable(MediaControl, { __call = MediaControl.new })
