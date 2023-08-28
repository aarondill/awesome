local awful = require("awful")
local bind = require("util.bind")
local gtable = require("gears.table")
local read_async = require("util.file.read_async")
local write_async = require("util.file.write_async")
local filepath = "/tmp/awesomewm-last-selected-tags"
awesome.connect_signal("exit", function(reason_restart)
  if not reason_restart then return end
  local str = ""
  for s in screen do
    local indicies = gtable.map(function(tag)
      return tag and tag.index
    end, s.selected_tags)
    str = ("%s%s\n"):format(str, table.concat(indicies, " "))
  end
  write_async(filepath, str)
end)

awesome.connect_signal(
  "startup",
  bind(read_async, filepath, function(content)
    if not content then return end

    local screen_tags = {}
    for line in content:gmatch("(.*)\n") do
      local selected_tags = {}
      for match in line:gmatch("%d+") do
        table.insert(selected_tags, tonumber(match))
      end
      table.insert(screen_tags, selected_tags)
    end

    for s in screen do
      local sel_tags = screen_tags[s.index]
      if #sel_tags > 0 then awful.tag.viewnone(s) end
      for _, i in ipairs(sel_tags) do
        local scr_tag = s.tags[i]
        if scr_tag then scr_tag.selected = true end
      end
    end

    os.remove(filepath)
  end)
)
