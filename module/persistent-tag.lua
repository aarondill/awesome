local atag = require("awful.tag")
local capi = require("capi")
local new_file_for_path = require("util.file.new_file_for_path")
local screen = require("util.types.screen")
local stream = require("stream")
local strings = require("util.strings")
local filepath = "/tmp/awesomewm-last-selected-tags"
capi.awesome.connect_signal("exit", function(reason_restart)
  if not reason_restart then return end
  local str = stream
    .new(screen.iterator())
    :map(function(s) ---@param s AwesomeScreenInstance
      return stream.new(s.selected_tags):map(function(tag) return tag.index end):join(" ")
    end)
    :join("\n")
  -- Write synchronously so it's written before awesome closes!
  return new_file_for_path(filepath):replace_contents(str, nil, false, "REPLACE_DESTINATION")
end)

capi.awesome.connect_signal("startup", function()
  require("module.tags") -- ensure that tags are properly initialized
  -- This is intentionally synchronous to ensure it's done *before* user control.
  local file = new_file_for_path(filepath)
  local contents = file:load_contents()
  if not contents then return end -- file doesn't exist

  local screen_tags = stream ---@type (number[])[]
    .new(strings.split(contents, "\n"))
    :map(function(line)
      return (
        stream
          .nonnil(line:gmatch("%d+")) -- line:gmatch returns a stateful iterator
          :map(tonumber)
          :toarray() ---@type number[]
      )
    end)
    :toarray()

  for s in capi.screen do
    local sel_tags = screen_tags[s.index] or {}
    if #sel_tags > 0 then atag.viewnone(s) end
    for _, i in ipairs(sel_tags) do
      local scr_tag = s.tags[i]
      if scr_tag then scr_tag.selected = true end
    end
  end

  return file:delete() -- delete the file after we've successfully loaded all contents
end)
