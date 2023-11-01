local awful = require("awful")
local capi = require("capi")
local filepath = "/tmp/awesomewm-last-selected-tags"
capi.awesome.connect_signal("exit", function(reason_restart)
  if not reason_restart then return end
  local t = {}
  for s in capi.screen do ---@cast s AwesomeScreenInstance
    local indicies = {}
    for _, tag in ipairs(s.selected_tags) do
      table.insert(indicies, tag.index)
    end
    table.insert(t, table.concat(indicies, " "))
  end
  local str = table.concat(t, "\n")
  -- Write synchronously so it's written before awesome closes!
  local f = io.open(filepath, "w+")
  if not f then return error("Could not open file " .. filepath) end
  f:write(str)
  return f:close()
end)

capi.awesome.connect_signal("startup", function()
  -- This is intentionally synchronous to ensure it's done *before* user control.
  local f = io.open(filepath, "r")
  if not f then return end -- file doesn't exist

  local screen_tags = {}
  for line in f:lines("l") do
    local selected_tags = {}
    for match in line:gmatch("%d+") do
      table.insert(selected_tags, tonumber(match))
    end
    table.insert(screen_tags, selected_tags)
  end
  f:close()

  for s in capi.screen do
    local sel_tags = screen_tags[s.index]
    if #sel_tags > 0 then awful.tag.viewnone(s) end
    for _, i in ipairs(sel_tags) do
      local scr_tag = s.tags[i]
      if scr_tag then scr_tag.selected = true end
    end
  end

  return os.remove(filepath)
end)
