local IconButton = require("widget.material.icon-button")
local apps = require("configuration.apps")
local awful = require("awful")
local bind = require("util.bind")
local capi = require("capi")
local concat_command = require("util.concat_command")
local gtable = require("gears.table")
local hotkeys_popup = require("awful.hotkeys_popup")
local icons = require("theme.icons")
local menubar = require("menubar")
local wibox = require("wibox")

---Create a button widget which will launch a command.
---@param args LauncherArgs? Standard widget table arguments, plus image for the image path
---@param menu table
---and command for the command to run on click, or either menu to create menu.
---@return table launcher_widget
local function launcher_new(args, menu)
  args = args or {}
  if not menu then
    return wibox.widget({ -- empty widget
      widget = wibox.widget.base.empty_widget,
    })
  end
  local opts = gtable.crush({ image = icons.launcher }, args, true)
  opts.buttons = gtable.join(
    awful.button.new({}, 1, nil, apps.open.rofi),
    awful.button.new({}, 3, nil, bind.with_args(menu.toggle, menu))
  )
  opts.widget = IconButton
  return wibox.widget(opts)
end
---@class LauncherArgs
---@field left integer?
---@field right integer?
---@field top integer?
---@field bottom integer?
---@field margins integer?
---@field image string?

---Create a launcher widget and a main menu
---@param args LauncherArgs?
---@return table widget
function Launcher(args)
  -- function(item, menu) end
  local menu_awesome = {
    "Awesome",
    {
      { "hotkeys", bind.with_args(hotkeys_popup.show_help) },
      { "manual", bind.with_args(apps.open.terminal, { "man", "awesome" }) },
      { "edit config", bind.with_args(apps.open.editor, capi.awesome.conffile) },
      { "restart", capi.awesome.restart }, -- doesn't take arguuments anyways
      { "quit", bind.with_args(capi.awesome.quit) },
    },
  }
  local menu_terminal = { "Open Terminal", bind.with_args(apps.open.terminal) }

  do
    local has_fdo, fdo_menu = pcall(require, "freedesktop.menu")
    if has_fdo then
      local menu = fdo_menu.build({ before = { menu_awesome }, after = { menu_terminal } })
      return launcher_new(args, menu)
    end
  end

  local menu = awful.menu.new({ items = { menu_awesome, menu_terminal } })

  do -- Load Debian menu entries
    local has_debian, debian = pcall(require, "debian.menu")
    if has_debian then
      for i, v in ipairs(debian.menu.Debian_menu.Debian) do
        menu:add(v, i + 1) -- Insert each entry after the first one
      end
    end
  end

  return launcher_new(args, menu)
end

-- Menubar configuration
-- Set the terminal for applications that require it
-- HACK: to stringify the terminal, since a table is not permitted here.
menubar.utils.terminal = concat_command(apps.default.terminal, "")
menubar.utils.wm_name = "" -- The logic to check is disabled if this is empty :)

return Launcher
