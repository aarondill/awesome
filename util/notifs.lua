local bind = require("util.bind")
local gtable = require("gears.table")
local naughty = require("naughty")

local M = {}

---@alias screen table
---@alias gears.shape table
---@alias gears.opacity table
---@alias gears.margin table
---@alias notification table
---@alias naughty.notificationClosedReason table

---@class NotifyOpts
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
---@field args.ignore_suspend? boolean If set to true this notification will be shown even if notifications are suspended via `naughty.suspend`. [Default: false]

---Do NOT call this function directly. Instead, call notify, warn, etc...
---@param text string?
---@param opts NotifyOpts This *will* be modified.
---@return table|nil
local function _notify(text, opts)
  text = text or opts.text or opts.message
  text = tostring(text)
  if awesome.version <= "v4.3" then
    opts.text = text
    return naughty.notify(opts)
  else
    opts.message, opts.text = text, nil
    return naughty.notification(opts)
  end
end

---@alias loglevel "low"| "normal"| "critical"| "ok"| "info"| "warn"
---Create a notification.
---@param text? string The text to display
---@param loglevel? loglevel  the naughty.preset.LEVEL to use [Default: "normal"]
---@param opts? NotifyOpts
---usage:
---```lua
---notify("You're idling", "normal", { title = "Achtung!", timeout = 0 })
---```
---@return notification? notification The notification object, or nil in case a notification was not displayed.
---@overload fun(opts: NotifyOpts): notification?
---@overload fun(loglevel: loglevel, opts?: NotifyOpts): notification?
function M.notify(loglevel, text, opts)
  if type(loglevel) == "table" then
    opts = loglevel
    loglevel = nil
    text = nil
  elseif type(text) == "table" then
    opts = text
    text = nil
  end

  opts = opts or {}
  opts.preset = (loglevel and naughty.config.presets[loglevel]) or opts.preset

  -- naughty.config.presets.
  return _notify(text, opts)
end

---@alias logFunc fun(text: string, opts?: NotifyOpts): notification? |  fun(opts?: NotifyOpts): notification?

---@type logFunc
M.low = bind(M.notify, "low")
---@type logFunc
M.normal = bind(M.notify, "normal")
---@type logFunc
M.critical = bind(M.notify, "critical")
---@type logFunc
M.ok = bind(M.notify, "ok")
---@type logFunc
M.info = bind(M.notify, "info")
---@type logFunc
M.warn = bind(M.notify, "warn")

return M
