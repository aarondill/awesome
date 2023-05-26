local awful = require("awful")
local layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.fair,
	awful.layout.suit.max,
	awful.layout.suit.magnifier,
	awful.layout.suit.floating,
}

--HACK: Show them all!
-- layouts = {
-- 	-- awful.layout.suit.corner.nw,
-- 	-- awful.layout.suit.corner.sw,
-- 	-- awful.layout.suit.corner.se,
-- 	-- awful.layout.suit.max,
-- 	-- awful.layout.suit.max.fullscreen,
--
-- 	awful.layout.suit.tile,
-- 	awful.layout.suit.tile.left,
-- 	awful.layout.suit.tile.bottom,
-- 	awful.layout.suit.tile.top,
-- 	awful.layout.suit.spiral.dwindle,
-- 	awful.layout.suit.spiral,
-- 	awful.layout.suit.fair.horizontal,
-- 	awful.layout.suit.fair,
-- 	awful.layout.suit.floating,
-- 	awful.layout.suit.magnifier,
-- 	awful.layout.suit.corner.ne,
-- }
return layouts
