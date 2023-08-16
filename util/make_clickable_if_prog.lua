-- replace_if_present(cmd, replace_widget, replace_in, function(path, replace_widget, replace_in)
-- Do something with path (guarenteed to be non-nil)
-- end)
---@param cmd string|string[]
---@param replace_widget table
---@param replace_in table
---@param cb fun(path:string, replace_widget:table, replace_in:table)
local function make_clickable_if_prog(cmd, replace_widget, replace_in, cb)
  local gears = require("gears")
  local awful = require("awful")
  local installed = require("util.installed")
  local replace_in_widget = require("util.replace_in_widget")
  if not cmd or not replace_widget or not replace_in or not cb then error("Replace_if_present requires 4 arguments") end
  if type(cmd) == "table" then cmd = cmd[1] end
  --stylua: ignore
  if not cmd then return end
  installed(cmd, function(path_or_nil)
    if path_or_nil then
      local clickable = require("widget.material.clickable-container")(replace_widget)
      clickable:buttons(gears.table.join(
        -- Call callback on click
        awful.button({}, 1, nil, function()
          return cb(path_or_nil, replace_widget, replace_in)
        end)
      ))
      replace_in_widget(replace_in, replace_widget, clickable)
    end
  end)
end
return make_clickable_if_prog
