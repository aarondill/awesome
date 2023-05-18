local has_posix, posix = pcall(require, "posix.stdlib")
local naughty = require("naughty")

local function setenv()
	pcall(function()
		posix.setenv("GTK_IM_MODULE", "xim") -- Fix for browsers
		posix.setenv("QT_IM_MODULE", "xim") -- Not sure if this works or not, but whatever
		posix.setenv("XMODIFIERS", "@im=ibus")
		posix.setenv("XDG_CURRENT_DESKTOP", "Gnome")
		posix.setenv("QT_QPA_PLATFORMTHEME", "gtk2")
	end)
end

if not has_posix then
	naughty.notify({
		presets = naughty.config.presets.warn,
		text = "Could not find luaposix.stdlib! Please ensure it's available at posix/stdlib.",
		title = "Warning: ",
		timeout = 0,
	})
end
-- If no posix module is available, return an empty function
return (has_posix and setenv) or function() end
