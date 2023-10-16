---@alias widget table

---Returns the first (or index) result of get_children_by_id
---Is same as: widget:get_children_by_id(id)[index] except that it won't error if no child is found.
---@param widget widget
---@param id string
---@param index integer? default: 1
---@return widget?
local function get_child_by_id(widget, id, index)
  local children = widget:get_children_by_id(id) ---@type widget[]?
  return children and children[index or 1]
end
return get_child_by_id
