local layout_suit = require("awful.layout.suit")
local layouts = {
  layout_suit.tile,
  layout_suit.fair,
  layout_suit.max,
  layout_suit.max.fullscreen,
  layout_suit.magnifier,
  layout_suit.floating,
}

return layouts
