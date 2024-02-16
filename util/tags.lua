local atag = require("awful.tag")
local screen = require("util.types.screen")
local M = {}

---Get a tag by index
---@param i integer index
---@param c AwesomeClientInstance | AwesomeScreenInstance | nil the client (or screen) whose screen the tag belongs to default focused.
---@return AwesomeTagInstance?
function M.get_tag(i, c)
  local s = screen.get(c) or screen.focused()
  if not s then return nil end
  local tag = s.tags[i]
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
    atag.viewtoggle(tag)
  else
    tag:view_only()
  end
  return tag
end

return M
