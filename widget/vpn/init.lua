local abutton = require("awful.button")
local dpi = require("beautiful").xresources.apply_dpi
local atooltip = require("awful.tooltip")
local beautiful = require("beautiful")
local clickable_container = require("widget.material.clickable-container")
local compat = require("util.awesome.compat")
local concat_command = require("util.command.concat_command")
local gtimer = require("gears.timer")
local spawn = require("util.spawn")
local wibox = require("wibox")
local widgets = require("util.awesome.widgets")

local connect_options = { "-f", "-p", "udp" }
local protonvpn_cli_path = "protonvpn-cli"
local timeout = 10

---@param args string[]|string
---@param callback fun(succuss: boolean, stdout: string, stderr: string): any?
local function spawn_proton(args, callback)
  local info = spawn.async(
    concat_command({ protonvpn_cli_path }, args),
    function(stdout, stderr, reason, exitcode) return callback(spawn.is_normal_exit(reason, exitcode), stdout, stderr) end
  )
  if info then return end -- Already spawned
  return callback(false, "Failed to spawn process: " .. protonvpn_cli_path, "")
end

local format = {
  pending = "…",
  on = '<span color="#22FF22">⚛</span>',
  off = '<span color="#FFD700">⏻</span>',
  error = '<span color="#FF2222">⚠</span>',
}
local wdg = wibox.widget({
  {
    {
      id = "textbox",
      markup = format.pending,
      [compat.widget.halign] = "center",
      valign = "center",
      widget = wibox.widget.textbox,
    },
    margins = dpi(5),
    layout = wibox.container.margin,
  },
  widget = clickable_container,
})
wdg.tooltip = atooltip({
  mode = "outside",
  visible = false,
  preferred_positions = { "bottom" },
  ontop = true,
  border_width = 2,
  border_color = beautiful.bg_focus,
  widget = wibox.widget.textbox,
})

---@param markup string
---@param tooltip_text string
---@param _status boolean?
function wdg:__set(markup, tooltip_text, _status)
  widgets.get_by_id(self, "textbox"):set_markup(markup)
  self.tooltip.text = tooltip_text
  self._cached_status = _status
end
---@param connected boolean
---@param tooltip_text string
function wdg:set_status(connected, tooltip_text)
  return wdg:__set(connected and format.on or format.off, tooltip_text, connected)
end
---@param tooltip_text string
-- Assume disconnected on error. Worst case, the user will reconnect when they expect to disconnect.
function wdg:set_error(tooltip_text) return wdg:__set(format.error, tooltip_text, false) end
---@param tooltip_text string
function wdg:set_status_pending(tooltip_text) return wdg:__set(format.pending, tooltip_text, nil) end

function wdg:connect()
  self:set_status_pending("Connecting…")
  return spawn_proton(concat_command({ "c" }, connect_options), function(succ, stdout, stderr)
    if not succ then return self:set_error(table.concat({ stdout, stderr }, "\n")) end
    return self:set_status(true, stdout)
  end)
end
function wdg:disconnect()
  self:set_status_pending("Disconnecting…")
  return spawn_proton({ "d" }, function(succ, stdout, stderr)
    if not succ then return self:set_error(table.concat({ stdout, stderr }, "\n")) end
    return self:set_status(false, stdout)
  end)
end
---May do nothing if currently connecting/disconnecting
function wdg:toggle()
  if self._cached_status == nil then return end
  if self._cached_status then return self:disconnect() end
  return self:connect()
end
---@param callback? fun(enabled: boolean): any?
function wdg:update(callback)
  return spawn_proton({ "s" }, function(succ, stdout, stderr)
    if not succ or stderr ~= "" then return wdg:set_error(table.concat({ stdout, stderr }, "\n")) end
    local connected = not stdout:find("No active Proton VPN connection.", 1, true)
    assert(stdout ~= nil, "stdout is nil")
    wdg:set_status(connected, stdout)
    if callback then return callback(connected) end
  end)
end
---@return boolean active nil if pending
function wdg:enabled() return self._cached_status end

---TODO: allow multiple instances
local function create(args)
  args = args or {}
  local args_format = args.format or {}
  connect_options = args.connect_options or connect_options
  timeout = args.timeout or timeout
  format.on, format.off = args_format.on or format.on, args_format.off or format.off
  protonvpn_cli_path = args.protonvpn_cli_path or protonvpn_cli_path

  local font = args.font or beautiful.font
  wdg.tooltip.font = font
  wdg.tooltip:add_to_object(wdg)
  wdg:get_children_by_id("textbox")[1].font = font
  wdg:buttons(abutton({}, 1, function() wdg:toggle() end))
  gtimer.new({
    timeout = timeout,
    callback = function() return wdg:update() end,
    call_now = true,
    autostart = true,
  })
  return wdg
end
return create
