local IconButton = require("widget.material.icon-button")
local apps = require("configuration.apps")
local awful = require("awful")
local bind = require("util.bind")
local concat_command = require("util.concat_command")
local gtable = require("gears.table")
local hotkeys_popup = require("awful.hotkeys_popup")
local icons = require("theme.icons")
local menubar = require("menubar")
local spawn = require("util.spawn")
local wibox = require("wibox")
local function open_main_menu()
  local pid_or_err = spawn.noninteractive(apps.default.rofi)
  -- The return value will be a string in case of failure
  if type(pid_or_err) == "string" then
    local s = awful.screen.focused()
    if s and s.run_promptbox then s.run_promptbox:run() end
  end
end

---Create a button widget which will launch a command.
---@param args table Standard widget table arguments, plus image for the image path
---and command for the command to run on click, or either menu to create menu.
---@return table launcher_widget
local function launcher_new(args)
  if not args.menu then
    return wibox.widget({ -- empty widget
      widget = wibox.widget.base.empty_widget,
    })
  end
  return wibox.widget({
    margins = args.margins,
    image = args.image or icons.launcher,
    buttons = gtable.join(
      awful.button.new({}, 1, nil, open_main_menu),
      awful.button.new({}, 3, nil, bind.with_args(args.menu.toggle, args.menu))
    ),
    widget = IconButton,
  })
end

function Launcher(_)
  -- Create a launcher widget and a main menu

  -- function(item, menu) end
  local menu_awesome = {
    "Awesome",
    {
      { "hotkeys", bind.with_args(hotkeys_popup.show_help) },
      { "manual", bind.with_args(apps.open.terminal, { "man", "awesome" }) },
      { "edit config", bind.with_args(apps.open.editor, awesome.conffile) },
      { "restart", awesome.restart }, -- doesn't take arguuments anyways
      { "quit", bind.with_args(awesome.quit) },
    },
  }
  local menu_terminal = { "Open Terminal", bind.with_args(apps.open.terminal) }

  do
    local has_fdo, fdo_menu = pcall(require, "freedesktop.menu")
    if has_fdo then
      local menu = fdo_menu.build({ before = { menu_awesome }, after = { menu_terminal } })
      return launcher_new({ menu = menu })
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

  return launcher_new({ menu = menu })
end

-- Menubar configuration
-- Set the terminal for applications that require it
-- HACK: to stringify the terminal, since a table is not permitted here.
menubar.utils.terminal = concat_command(apps.default.terminal, "")
menubar.utils.wm_name = "" -- The logic to check is disabled if this is empty :)

return Launcher
