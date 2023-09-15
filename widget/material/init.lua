local require = require("util.rel_require")

return {
  clickable_container = require(..., "clickable_container"), ---@module 'widget.material.clickable-container'
  icon_button = require(..., "icon-button"), ---@module 'widget.material.icon-button'
  icon = require(..., "icon"), ---@module 'widget.material.icon'
  slider = require(..., "slider"), ---@module 'widget.material.slider'
  ---@deprecated
  list_item = require(..., "list-item"), ---@module 'widget.material.list-item'
}
