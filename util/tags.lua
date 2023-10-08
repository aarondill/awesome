local awful = require("awful")
local M = {}

---@param o AwesomeClientInstance | AwesomeScreenInstance | nil The objec to find screen on. Default is focused screen.
function M.get_screen(o)
  if not o then return awful.screen.focused() end
  return o.screen or o
end
---Get a tag by index
---@param i integer index
---@param c AwesomeClientInstance | AwesomeScreenInstance | nil the client (or screen) whose screen the tag belongs to default focused.
---@return AwesomeTagInstance?
function M.get_tag(i, c)
  local screen = M.get_screen(c)
  if not screen then return nil end
  local tag = screen.tags[i]
  return tag
end
---Show a tag by index.
---@param i integer index of the tag to show
---@param add boolean? whether to add (toggle) the tag, or show *just* it. default false
---@return AwesomeTagInstance? tag the tag shown
function M.show_tag(i, add)
  local tag = M.get_tag(i)
  if not tag then return end
  if add then
    awful.tag.viewtoggle(tag)
  else
    tag:view_only()
  end
  return tag
end

return M
