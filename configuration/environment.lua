local has_posix, posix = pcall(require, "posix.stdlib")
local naughty = require("naughty")

local function setenv()
	pcall(function()
		posix.setenv("GTK_IM_MODULE", "xim") -- Fix for browsers
		posix.setenv("QT_IM_MODULE", "xim") -- Not sure if this works or not, but whatever
		posix.setenv("XMODIFIERS", "@im=ibus")
		posix.setenv("XDG_CURRENT_DESKTOP", "GNOME:AWESOME")
		posix.setenv("QT_QPA_PLATFORMTHEME", "gtk2")
		posix.setenv("SHLVL", "0") -- Fix terminals opened in AwesomeWM
		posix.setenv("NO_AT_BRIDGE", "1") -- Don't try to connect to an accessibility bus
		posix.setenv("_JAVA_AWT_WM_NONREPARENTING", "1") -- expose awesome as a non-reparenting window to java
	end)
end

if not has_posix then
	naughty.notify({
		presets = naughty.config.presets.warn,
		text = "Could not find luaposix.stdlib! Please ensure it's available at posix/stdlib.",
		title = "Warning: ",
		timeout = 0,
	})
	-- If no posix module is available, return an empty function
	return function() end
end
return setenv
