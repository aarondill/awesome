local abutton = require("awful.button")
local bind = require("util.bind")
local clickable_container = require("widget.material.clickable-container")
local replace_in_widget = require("util.replace_in_widget")
local GLib = require("lgi").GLib
local which = GLib.find_program_in_path

-- replace_if_present(cmd, replace_widget, replace_in, function(path, replace_widget, replace_in)
-- Do something with path (guarenteed to be non-nil)
-- end)
---@param cmd string|string[]
---@param replace_widget table
---@param replace_in table
---@param cb fun(path:string, replace_widget:table, replace_in:table)
local function make_clickable_if_prog(cmd, replace_widget, replace_in, cb)
  if not cmd or not replace_widget or not replace_in or not cb then error("Replace_if_present requires 4 arguments") end
  if type(cmd) == "table" then cmd = assert(cmd[1]) end
  local path_or_nil = which(cmd)
  if not path_or_nil then return end
  local buttons = abutton({}, 1, nil, bind.with_args(cb, path_or_nil, replace_widget, replace_in)) -- Call callback on click
  local clickable = clickable_container(replace_widget, buttons)
  return replace_in_widget(replace_in, replace_widget, clickable)
end
return make_clickable_if_prog
