local awful = require("awful")
awesome.connect_signal("exit", function(reason_restart)
	if not reason_restart then
		return
	end

	local str = ""
	for s in screen do
		local tags = s.selected_tags
		for _, tag in ipairs(tags) do
			str = str .. tag.index .. "\n"
		end
		str = str .. "\n"
	end

	-- empty line means next screen
	local file = io.open("/tmp/awesomewm-last-selected-tags", "w+")
	if file then
		file:write(str)
		file:close()
	end
end)

awesome.connect_signal("startup", function()
	local file = io.open("/tmp/awesomewm-last-selected-tags", "r")
	if not file then
		return
	end

	local screen_tags = {}
	local scrI = 1
	local selected_tags = {}
	for line in file:lines() do
		if line == "\n" or line == "" then
			screen_tags[scrI] = selected_tags
			selected_tags = {}
			scrI = scrI + 1
		end
		table.insert(selected_tags, tonumber(line))
	end
	-- awful.screen[s].tags
	for s in screen do
		local sel_tags = screen_tags[s.index]
		if sel_tags then
			for _, tag in ipairs(sel_tags) do
				local t = s.tags[tag]
				if t then
					t.selected = true
				end
			end
		end
	end

	file:close()
end)
