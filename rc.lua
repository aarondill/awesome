-- TODO:
-- Create global tablist for use in all cases

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Focus on mouse over
require("awful.autofocus")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Show a notification if something goes wrong
require("modules.error_handling")

-- theme(themeName)
require("theme")(nil)

-- Layout
require("layout")

require("modules.rules")
require("modules.signals")

-- Different tags for each wallpaper
require("modules.wallpaper")
