local gears = require("gears")

local function setup_wallpapers()
	-- Set according to wallpaper directory
	local path = gears.filesystem.get_configuration_dir() .. "wallpapers"
	-- Set to number of used tags
	local num_tabs = 9
	-- Other variables
	local default = path .. "/1.jpg"
	if not gears.filesystem.file_readable(default) then
		default = gears.filesystem.get_themes_dir() .. "default/background.png"
	end

	local function get_wp_path(num)
		local wp = string.format("%s/%s.jpg", path, tostring(num))
		if gears.filesystem.file_readable(wp) then
			return wp
		else
			return default
		end
	end
	-- For each screen
	for s = 1, screen.count() do
		-- Set wallpaper on first tab (else it would be empty at start up)
		gears.wallpaper.maximized(get_wp_path(1), s)
		-- Go over each tab
		for t = 1, num_tabs do
			screen[s].tags[t]:connect_signal("property::selected", function(tag)
				-- And if selected
				if tag.selected then
					-- Set wallpaper
					gears.wallpaper.maximized(get_wp_path(t), s)
				end
			end)
		end
	end
end
setup_wallpapers()
