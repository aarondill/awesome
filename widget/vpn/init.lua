local abutton = require("awful.button")
local atooltip = require("awful.tooltip")
local beautiful = require("beautiful")
local bind = require("util.bind")
local clickable_container = require("widget.material.clickable-container")
local compat = require("util.awesome.compat")
local concat_command = require("util.command.concat_command")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local spawn = require("util.spawn")
local strings = require("util.strings")
local tables = require("util.tables")
local wibox = require("wibox")
local widgets = require("util.awesome.widgets")
local dpi = require("beautiful").xresources.apply_dpi

---@class VpnWidgetArgs
local default_args = {
  ---Options to pass to protonvpn-cli connect
  connect_options = { "-f", "-p", "udp" },
  ---THe path to the protonvpn-cli executable
  protonvpn_cli_path = "protonvpn-cli",
  ---How often to check the connection status
  timeout = 10,
  ---Markup for the textbox
  format = {
    pending = "…",
    on = '<span color="#22FF22">⚛</span>',
    off = '<span color="#FFD700">⏻</span>',
    error = '<span color="#FF2222">⚠</span>',
  },
  ---Font to use for the textbox/tooltip
  font = beautiful.font,
}

---@class VpnWidget
local VpnWidget = {
  opts = {}, ---@type VpnWidgetArgs
  tooltip = {}, ---@type widget awful.tooltip
  timer = {}, ---@type table gears.timer
}

---@param args string[]|string
---@param callback fun(succuss: boolean, stdout: string, stderr: string): any?
function VpnWidget:spawn_proton(args, callback)
  local path = self.opts.protonvpn_cli_path
  assert(path ~= nil, "protonvpn_cli_path is nil")
  local info = spawn.async(concat_command({ path }, args), function(stdout, stderr, reason, exitcode) --
    return callback(spawn.is_normal_exit(reason, exitcode), stdout, stderr)
  end)
  if info then return end -- Already spawned
  if self.timer.started then self.timer:stop() end -- If we failed to spawn, stop the timer. There's no point in continuing to try.
  return callback(false, "Failed to spawn process: " .. path, "")
end

---@param markup string
---@param tooltip_text string
---@param status boolean?
function VpnWidget:__set(markup, tooltip_text, status)
  widgets.get_by_id(self, "textbox"):set_markup(markup)
  tooltip_text = strings.trim(tooltip_text)
  self.tooltip.text = tooltip_text ~= "" and tooltip_text or "<Empty Output>"
  self._cached_status = status
end
---@param connected boolean
---@param tooltip_text string
function VpnWidget:set_status(connected, tooltip_text)
  if not self.timer.started then self.timer:start() end -- Resume timer if paused
  local format = connected and self.opts.format.on or self.opts.format.off
  assert(format ~= nil, "format is nil")
  return self:__set(format, tooltip_text, connected)
end
-- Assume disconnected on error. Worst case, the user will reconnect when they expect to disconnect.
-- Don't resume the timer on error, this forces the user to press the button to dismiss the error.
---@param tooltip_text string
function VpnWidget:set_error(tooltip_text) return self:__set(self.opts.format.error, tooltip_text, false) end
---@param tooltip_text string
function VpnWidget:set_status_pending(tooltip_text)
  if self.timer.started then self.timer:stop() end -- Pause timer while pending
  return self:__set(self.opts.format.pending, tooltip_text, nil)
end

function VpnWidget:connect()
  self:set_status_pending("Connecting…")
  return self:spawn_proton(concat_command({ "c" }, self.opts.connect_options), function(succ, stdout, stderr)
    self.timer:again() -- Resume timer
    if not succ then return self:set_error(table.concat({ stdout, stderr }, "\n")) end
    return self:set_status(true, stdout)
  end)
end
function VpnWidget:disconnect()
  self:set_status_pending("Disconnecting…")
  return self:spawn_proton({ "d" }, function(succ, stdout, stderr)
    if not succ then return self:set_error(table.concat({ stdout, stderr }, "\n")) end
    return self:set_status(false, stdout)
  end)
end
---May do nothing if currently connecting/disconnecting
function VpnWidget:toggle()
  if self._cached_status == nil then return end
  if self._cached_status then return self:disconnect() end
  return self:connect()
end
---@param callback? fun(enabled: boolean): any?
function VpnWidget:update(callback)
  return self:spawn_proton({ "s" }, function(succ, stdout, stderr)
    if not succ or stderr ~= "" then return self:set_error(table.concat({ stdout, stderr }, "\n")) end
    local connected = not stdout:find("No active Proton VPN connection.", 1, true)
    assert(stdout ~= nil, "stdout is nil")
    self:set_status(connected, stdout)
    if callback then return callback(connected) end
  end)
end
---@return boolean active nil if pending
function VpnWidget:enabled() return self._cached_status end

---@class VpnWidgetArgs
---@field format? { on?: string, off?: string, error?: string, pending?: string }
---@field connect_options? string[]
---@field timeout? number
---@field protonvpn_cli_path? string
---@field font? string

---@param args? VpnWidgetArgs
function VpnWidget.new(args)
  ---@type VpnWidgetArgs
  local opts = tables.deep_extend("force", tables.clone(default_args), args or {})
  local wdg
  wdg = wibox.widget({
    {
      {
        id = "textbox",
        markup = opts.format.pending,
        font = opts.font,
        [compat.widget.halign] = "center",
        valign = "center",
        widget = wibox.widget.textbox,
      },
      margins = dpi(5),
      layout = wibox.container.margin,
    },
    buttons = abutton.new({}, 1, function() return wdg:toggle() end),
    widget = clickable_container,
  })
  gtable.crush(wdg, VpnWidget, true) ---@cast wdg VpnWidget
  wdg.opts = opts
  wdg.tooltip = atooltip({
    objects = { wdg },
    font = opts.font,
    mode = "outside",
    visible = false,
    preferred_positions = { "bottom" },
    ontop = true,
    border_width = 2,
    border_color = beautiful.bg_focus,
    widget = wibox.widget.textbox,
  })
  wdg:set_status_pending("Checking…") --- Set initial status
  wdg.timer = gtimer.new({
    timeout = opts.timeout,
    callback = bind.with_args(wdg.update, wdg),
    call_now = true,
    autostart = true,
  })
  return wdg
end
return VpnWidget.new
