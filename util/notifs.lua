local bind = require("util.bind")
local gtable = require("gears.table")
local naughty = require("naughty")

---@alias gears.shape table
---@alias gears.opacity table
---@alias gears.margin table
---@alias notification table
---@alias naughty.notificationClosedReason table

---@class NotifyOpts
---@field once? boolean Whether the notification should only be shown once [Default: false]
---@field message? string Text of the notification, used if text is not defined. [Default: nil]
---@field text? string Text of the notification. [Default: ""]
---@field title? string Title of the notification.
---@field timeout? integer Time in seconds after which popup expires. Set 0 for no timeout. [Default: 5]
---@field hover_timeout? integer Delay in seconds after which hovered popup disappears.
---@field screen? integer|screen Target screen for the notification. [Default: focused]
---@field position? "top_right" | "top_left" | "bottom_left" | "bottom_right" | "top_middle" | "bottom_middle" Corner of the workarea displaying the popups. [Default: "top_right"]
---@field ontop? boolean Boolean forcing popups to display on top. [Default: true]
---@field height? integer Popup height. [Default: `beautiful.notification_height` or auto]
---@field width? integer Popup width. [Default: `beautiful.notification_width` or auto]
---@field max_height? integer Popup maximum height. [Default: `beautiful.notification_max_height` or auto]
---@field max_width? integer Popup maximum width. [Default: `beautiful.notification_max_width` or auto]
---@field font? string Notification font. [Default: `beautiful.notification_font` or `beautiful.font` or `awesome.font`]
---@field icon? string Path to icon.
---@field icon_size? integer Desired icon size in px.
---@field fg? string Foreground color. [Default: `beautiful.notification_fg` or `beautiful.fg_focus` or `'#ffffff'`]
---@field bg? string Background color. [Default: `beautiful.notification_fg` or `beautiful.bg_focus` or `'#535d6c'`]
---@field border_width? integer Border width. [Default: `beautiful.notification_border_width` or 1]
---@field border_color? string Border color. [Default: `beautiful.notification_border_color` or `beautiful.border_focus` or `'#535d6c'`]
---@field shape? gears.shape Widget shape. [Default: `beautiful.notification_shape`]
---@field opacity? gears.opacity Widget opacity. [Default: `beautiful.notification_opacity`]
---@field margin? gears.margin Widget margin. [Default: `beautiful.notification_margin`]
---@field run? fun(n: notification) Function to run on left click.  The notification object will be passed to it as an argument.
---You need to call notification.die from there to dismiss the notification yourself. Ex: `notification.die(naughty.notificationClosedReason.dismissedByUser)`
---@field destroy? fun(reason: naughty.notificationClosedReason) Function to run when notification is destroyed.
---@field preset? table Table with any of the above parameters. Note: Any parameters specified directly in will override ones defined in the preset.
---@field replaces_id? integer Replace the notification with the given ID.
---@field actions? function[] Mapping that maps a string to a callback when this action is selected.
---@field ignore_suspend? boolean If set to true this notification will be shown even if notifications are suspended via `naughty.suspend`. [Default: false]

---@alias logFunc fun(text?: string, opts?: NotifyOpts): notification? |  fun(opts?: NotifyOpts): notification?

---@class NotifsClass
---@field low logFunc
---@field normal logFunc
---@field critical logFunc
---@field ok logFunc
---@field info logFunc
---@field warn logFunc
---@field low_once logFunc
---@field normal_once logFunc
---@field critical_once logFunc
---@field ok_once logFunc
---@field info_once logFunc
---@field warn_once logFunc
local M = {}

---A table for use in notify_once
local displayed_notifications = {}

---Do NOT call this function directly. Instead, call notify, warn, etc...
---@param text string?
---@param opts NotifyOpts This *will* be modified.
---@return table|nil
local function _notify(text, opts)
  text = text or opts.text or opts.message
  text = tostring(text)
  if opts.once then
    local tb = debug.traceback()
    if displayed_notifications[tb] == text then return end -- Only when text is same from the same place
    displayed_notifications[tb] = text
  end
  if naughty.notification then
    opts.message, opts.text = text, nil
    return naughty.notification(opts)
  else
    opts.text = text
    return naughty.notify(opts)
  end
end

---@param opts? NotifyOpts|string
local function has_msg(opts)
  return type(opts) == "table" and (opts.message or opts.text)
end
---@alias loglevel "low"| "normal"| "critical"| "ok"| "info"| "warn"
---Create a notification.
---@param text? string The text to display
---@param loglevel? loglevel  the naughty.preset.LEVEL to use [Default: "normal"]
---@param opts? NotifyOpts
---@param extra_opts? NotifyOpts Extra options to merge with opts. Mostly for use in library functions.
---usage:
---```lua
---notify("You're idling", "normal", { title = "Achtung!", timeout = 0 })
---```
---@return notification? notification The notification object, or nil in case a notification was not displayed.
---@overload fun(opts: NotifyOpts): notification?
---@overload fun(loglevel: loglevel, opts?: NotifyOpts): notification?
function M.notify(loglevel, text, opts, extra_opts)
  if type(text) == "table" and has_msg(text) and opts == nil then -- notify("warn", { opts }) || notify("warn", { opts }, nil, { extra_opts })
    opts = text
    text = nil
  elseif type(loglevel) == "table" and has_msg(loglevel) and text == nil and opts == nil then -- notify({ opts }) || notify({ opts }, nil, nil, { extra_opts })
    opts = loglevel
    loglevel = nil
  end

  opts = opts and gtable.clone(opts, true) or {}
  opts.preset = (loglevel and naughty.config.presets[loglevel]) or opts.preset
  if extra_opts then gtable.crush(opts, extra_opts) end

  return _notify(text, opts)
end
function M.notify_once(loglevel, text, opts)
  return M.notify(loglevel, text, opts, { once = true })
end

M.low = bind(M.notify, "low")
M.normal = bind(M.notify, "normal")
M.critical = bind(M.notify, "critical")
M.ok = bind(M.notify, "ok")
M.info = bind(M.notify, "info")
M.warn = bind(M.notify, "warn")
-- Once
M.low_once = bind(M.notify_once, "low")
M.normal_once = bind(M.notify_once, "normal")
M.critical_once = bind(M.notify_once, "critical")
M.ok_once = bind(M.notify_once, "ok")
M.info_once = bind(M.notify_once, "info")
M.warn_once = bind(M.notify_once, "warn")

return M
