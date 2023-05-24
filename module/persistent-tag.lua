local awful = require("awful")
local filepath = "/tmp/awesomewm-last-selected-tags"
awesome.connect_signal("exit", function(reason_restart)
	if not reason_restart then
		return
	end

	local file = io.open(filepath, "w+")
  --stylua: ignore
  if not file then return end

	for s in screen do
		for _, tag in ipairs(s.selected_tags) do
			file:write(tag.index, " ")
		end
		file:write("\n")
	end

	file:close()
end)

awesome.connect_signal("startup", function()
	local file = io.open(filepath, "r")
	if not file then
		return
	end

	local screen_tags = {}
	for line in file:lines("l") do
		local selected_tags = {}
		---@cast line string
		for match in line:gmatch("%d+") do
			table.insert(selected_tags, tonumber(match))
		end
		table.insert(screen_tags, selected_tags)
	end

	for s in screen do
		local sel_tags = screen_tags[s.index]
		if #sel_tags > 0 then
			awful.tag.viewnone(s)
		end
		for _, i in ipairs(sel_tags) do
			local scr_tag = s.tags[i]
			if scr_tag then
				scr_tag.selected = true
			end
		end
	end

	file:close()
	os.remove(filepath)
end)
