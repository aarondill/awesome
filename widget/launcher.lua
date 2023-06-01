local awful = require("awful")
local beautiful = require("beautiful")
local vars = require("variables")
local hotkeys_popup = require("awful.hotkeys_popup")
local menubar = require("menubar")

-- Load Debian menu entries
local has_debian, debian = pcall(require, "debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- Create a launcher widget and a main menu
local awesome_ctrl_menu = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},
	{ "manual", vars.terminal .. " -e man awesome" },
	{ "edit config", vars.editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}

local menu_awesome = { "Awesome", awesome_ctrl_menu, beautiful.awesome_icon }
local menu_terminal = { "Open Terminal", vars.terminal }

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

local launcher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mainmenu })

-- Menubar configuration
menubar.utils.terminal = vars.terminal -- Set the terminal for applications that require it

return { mylauncher = launcher, mymainmenu = mainmenu }
