---@diagnostic disable-next-line :undefined-global
local capi = { screen = screen }
local awful = require("awful")
local gtable = require("gears.table")
local filepath = "/tmp/awesomewm-last-selected-tags"
awesome.connect_signal("exit", function(reason_restart)
  if not reason_restart then return end
  local str = ""
  for s in capi.screen do
    local indicies = gtable.map(function(tag)
      return tag and tag.index
    end, s.selected_tags)
    str = ("%s%s\n"):format(str, table.concat(indicies, " "))
    -- Write synchronously so it's written before awesome closes!
    local f = assert(io.open(filepath, "w+"))
    f:write(str)
    f:close()
  end
end)

awesome.connect_signal("startup", function()
  -- This is intentionally synchronous to ensure it's done *before* user control.
  local f = io.open(filepath, "r")
  if not f then return end -- file doesn't exist
  local content = f:read("a")
  f:close()
  if not content then return end

  local screen_tags = {}
  for line in content:gmatch("(.*)\n") do
    local selected_tags = {}
    for match in line:gmatch("%d+") do
      table.insert(selected_tags, tonumber(match))
    end
    table.insert(screen_tags, selected_tags)
  end

  for s in capi.screen do
    local sel_tags = screen_tags[s.index]
    if #sel_tags > 0 then awful.tag.viewnone(s) end
    for _, i in ipairs(sel_tags) do
      local scr_tag = s.tags[i]
      if scr_tag then scr_tag.selected = true end
    end
  end

  os.remove(filepath)
end)
