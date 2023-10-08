local awful = require("awful")
local M = {}

---Get a tag by index
---@param i integer index
---@param c AwesomeClientInstance? the client whose screen the tag belongs to default focused.
---@return AwesomeTagInstance?
function M.get_tag(i, c)
  local screen = c and c.screen or awful.screen.focused() ---@type AwesomeScreenInstance
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
