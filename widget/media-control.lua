local awful = require("awful")
local beautiful = require("beautiful")
local concat_command = require("util.concat_command")
local gears = require("gears")
local spawn = require("util.spawn")
local wibox = require("wibox")

local widget_template = {
  {
    id = "icon",
    widget = wibox.widget.imagebox,
  },
  {
    id = "current_song",
    widget = wibox.widget.textbox,
  },
  layout = wibox.layout.fixed.horizontal,
  set_status = function(self, image)
    self.icon.image = image
  end,
  set_text = function(self, text)
    self.current_song.markup = text
  end,
}

---@class MediaControl.args
local defaults = {
  play_icon = beautiful.play,
  pause_icon = beautiful.pause,
  stop_icon = beautiful.stop,
  autohide = true,
  refresh_rate = 10,
  name = "",
  format = "{author} | {title}",
}

---@class MediaControl
local MediaControl = {}

---@param args MediaControl.args?
function MediaControl:new(args)
  return setmetatable({}, { __index = self }):init(args)
end

---@param args MediaControl.args?
---@return MediaControl
function MediaControl:init(args)
  args = args or {}
  self.icons = {
    play = args.play_icon or defaults.play_icon,
    pause = args.pause_icon or defaults.pause_icon,
    stop = args.stop_icon or defaults.stop_icon,
  }

  self.autohide = defaults.autohide
  if args.autohide ~= nil then self.autohide = args.autohide end
  self.widget = wibox.widget(widget_template)

  self.format = args.format or defaults.format
  self.name = args.name or defaults.name
  -- Higher refresh_rate == less CPU requirements
  -- Lower refresh_rate == better Widget response time
  self:watch(args.refresh_rate or defaults.refresh_rate)
  local spawn_update = function(_)
    self:status(function(status)
      self:update_widget_icon(status)
    end)
  end

  self.widget:buttons(awful.util.table.join(
    -- button 1: left click  - play/pause
    awful.button({}, 1, function()
      self:PlayPause(spawn_update)
    end),
    -- button 4: scroll up   - next song
    awful.button({}, 4, function()
      self:Next(spawn_update)
    end),
    -- button 5: scroll down - previous song
    awful.button({}, 5, function()
      self:Previous(spawn_update)
    end)
  ))

  return self.widget
end

---@param status string?
function MediaControl:update_widget_icon(status)
  status = status and string.gsub(status, "\n", "")
  self.widget:set_status((status == "Playing") and self.icons.play or self.icons.pause)
end

---@param text string
function MediaControl:update_widget_text(text)
  self.widget:set_text(gears.string.xml_escape(text))
  self.widget:set_visible(true)
end

function MediaControl:hide_widget()
  self.widget:set_text("Offline")
  self.widget:set_status(self.icons.stop)
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
---@param cb fun(success: boolean)
function MediaControl:PlayPause(cb)
  local pid = spawn.noninteractive(self:handle_name({ "playerctl", "play-pause" }))
  cb(type(pid) ~= "string")
end
---@param cb fun(success: boolean)
function MediaControl:Previous(cb)
  local pid = spawn.noninteractive(self:handle_name({ "playerctl", "previous" }))
  cb(type(pid) ~= "string")
end
---@param cb fun(success: boolean)
function MediaControl:Next(cb)
  local pid = spawn.noninteractive(self:handle_name({ "playerctl", "next" }))
  cb(type(pid) ~= "string")
end
function MediaControl:status(cb)
  awful.spawn.easy_async(self:handle_name({ "playerctl", "status" }), function(stdout, _, exit_reason, exit_code)
    if exit_reason ~= "exit" or exit_code ~= 0 then return cb(nil) end
    local status = string.match(stdout, "Playing") or string.match(stdout, "Paused")
    cb(status)
  end)
end

---Get info about the media source
---@param cb fun(info: MediaControl.info?)
function MediaControl:info(cb)
  awful.spawn.easy_async(self:handle_name({ "playerctl", "metadata" }), function(stdout, _, exit_reason, exit_code)
    if exit_reason ~= "exit" or exit_code ~= 0 then return cb(nil) end
    ---@class MediaControl.info
    local info = {
      artist = nil,
      title = nil,
      artUrl = nil,
      album = nil,
      albumArtist = nil,
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
    for k, v in string.gmatch(stdout, "[^:]+:(%S+)[%s]+([^\n]*)") do
      info[k] = v -- artUrl, artist, title, album, albumArtist, autoRating, etc...
    end
    cb(info)
  end)
end

function MediaControl:update_widget()
  self:status(function(status)
    -- Status unavailable? Media Player isn't active, hide the widget
    if not status then return self:hide_widget() end
    self:update_widget_icon(status)
    self:info(function(info)
      if info and info.artist and info.title then
        -- Change the artist and title fields in case they aren't nil

        -- format = "{author} | {title}"
        self:update_widget_text(string.format("%s | %s", info.artist, info.title))
      end
    end)
  end)
end

function MediaControl:watch(refresh_rate)
  gears.timer.new({
    timeout = refresh_rate,
    callback = function()
      self:update_widget()
    end,
    autostart = true,
    call_now = true,
  })
end

return setmetatable(MediaControl, { __call = MediaControl.new })
