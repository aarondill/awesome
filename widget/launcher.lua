local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local wibox = require("wibox")
local apps = require("configuration.apps")
local hotkeys_popup = require("awful.hotkeys_popup")
local menubar = require("menubar")
local icons = require("theme.icons")
local concat_command = require("util.concat_command")

-- Load Debian menu entries
local has_debian, debian = pcall(require, "debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

function Launcher(_)
  -- Create a launcher widget and a main menu
  local awesome_ctrl_menu = {
    {
      "hotkeys",
      function()
        hotkeys_popup.show_help(nil, awful.screen.focused())
      end,
    },
    {
      "manual",
      function()
        apps.open.terminal({ "man", "awesome" })
      end,
    },
    {
      "edit config",
      function()
        apps.open.editor(awesome.conffile)
      end,
    },
    { "restart", awesome.restart },
    {
      "quit",
      function()
        awesome.quit()
      end,
    },
  }

  local menu_awesome = { "Awesome", awesome_ctrl_menu }
  local menu_terminal = {
    "Open Terminal",
    function()
      apps.open.terminal()
    end,
  }

  local mainmenu
  if has_fdo then
    mainmenu = freedesktop.menu.build({
      before = { menu_awesome },
      after = { menu_terminal },
    })
  elseif has_debian then
    mainmenu = awful.menu({
      items = {
        menu_awesome,
        { "Debian", debian.menu.Debian_menu.Debian },
        menu_terminal,
      },
    })
  else
    mainmenu = awful.menu({ items = { menu_awesome, menu_terminal } })
  end

  local launcher = awful.widget.launcher({
    menu = mainmenu,
    image = icons.launcher,
    -- resize = true,
  })

  local m = dpi(6)
  return wibox.container.margin(launcher, m, m, m, m)
end

-- Menubar configuration
-- Set the terminal for applications that require it
-- HACK: to stringify the terminal, since a table is not permitted here.
menubar.utils.term = concat_command(apps.default.terminal, "")
menubar.utils.wm_name = "" -- The logic to check is disabled if this is empty :)

return Launcher
