local has_posix, posix = pcall(require, "posix.stdlib")
local naughty = require("naughty")
if has_posix then
	posix.setenv("GTK_IM_MODULE", "xim") -- Fix for Chrome
	posix.setenv("QT_IM_MODULE", "xim") -- Not sure if this works or not, but whatever
	posix.setenv("XMODIFIERS", "@im=ibus")
	posix.setenv("XDG_CURRENT_DESKTOP", "Unity")
	posix.setenv("QT_QPA_PLATFORMTHEME", "gtk2")
else
	naughty.notify({
		presets = naughty.config.presets.warn,
		text = "Could not find luaposix! Please ensure it's available.",
		title = "Could not find module",
	})
end
