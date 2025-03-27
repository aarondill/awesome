local GLib = require("lgi").GLib
local abutton = require("awful.button")
local bind = require("util.bind")
local clickable_container = require("widget.material.clickable-container")

local M = {}
---Replace all instances of from with to in the widget provided
---Recursive! could have bad performance on large widgets
---@param widget table the widget to replace child of
---@param from table what to remove
---@param to table what to replace with
function M.replace(widget, from, to)
  -- Likely passed wrong thing
  if widget.widget then widget = widget.widget end
  local seen = {}
  for _, c in ipairs(widget.children) do
    -- If nil or already seen (avoid infinite loop)
    if not c or seen[c] then goto continue end
    seen[c] = true
    if c.children then M.replace(c, from, to) end
    -- Replace "all" instances of the placeholder with the real thing
    if type(c.replace_widget) == "function" then c:replace_widget(from, to, true) end
    ::continue::
  end
end

---@param cmd string|string[]
---@param replace_widget table
---@param replace_in table
---@param cb? fun(cmd:string[], replace_widget:table, replace_in:table) defaults to spawning cmd
---@return widget clickable container/widget
function M.clickable_if(cmd, replace_widget, replace_in, cb)
  if not cmd or not replace_widget or not replace_in then error("clickable_if requires 3 arguments") end
  local cmdname = type(cmd) == "string" and cmd or assert(cmd[1], "no command specified")
  local path = GLib.find_program_in_path(cmdname)
  if not path then return replace_widget end
  cmd = type(cmd) == "table" and { cmdname, table.unpack(cmd) } or { cmdname }
  local callback = cb and bind.with_args(cb, cmd, replace_widget, replace_in)
    or bind.with_args(require("util.spawn").spawn, cmd)
  local buttons = abutton({}, 1, nil, callback)
  local clickable = clickable_container(replace_widget, buttons)
  M.replace(replace_in, replace_widget, clickable)
  return clickable
end

---@alias widget table

---Returns the first (or index) result of get_children_by_id
---Is same as: widget:get_children_by_id(id)[index] except that it won't error if no child is found.
---@param widget widget
---@param id string
---@param index integer? default: 1
---@return widget?
function M.get_by_id(widget, id, index)
  local children = widget:get_children_by_id(id) ---@type widget[]?
  return children and children[index or 1]
end

return M
