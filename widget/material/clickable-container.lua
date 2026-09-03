local capi = require("capi")
local wibox = require("wibox")

local set_alpha_cb
do
  -- Weak cache for functions, as they can be the same if given the same alpha
  ---@type { [string]: fun(container: container.background) }
  local cache = setmetatable({}, { __mode = "kv" })
  ---@param alpha string two digit hex value
  function set_alpha_cb(alpha)
    if not cache[alpha] then
      local c = ("#%s%s"):format("ffffff", alpha) -- white + alpha
      cache[alpha] = function(container) container:set_bg(c) end
    end
    return cache[alpha]
  end
end

---Create a clickable containter
---Call :buttons to set up the widget
---@param widget widget
---@param buttons unknown[]?
---@return container.background
local function build(widget, buttons)
  ---@type container.background
  local container = wibox.widget({
    widget,
    buttons = buttons,
    widget = wibox.container.background,
  })

  ---@class wibox
  ---@field is_moused_over boolean? -- This is an injected field!

  local saved_cursor, containing_wibox
  container:connect_signal("mouse::enter", function()
    -- Hm, no idea how to get the wibox from this signal's arguments...
    local w = capi.mouse.current_wibox
    if w and not w.is_moused_over then
      saved_cursor, containing_wibox = w.cursor, w
      -- Save the state to avoid race conditions between
      -- multiple clickable widgets in the same wibox
      w.is_moused_over = true
      w.cursor = "hand1"
    end
  end)
  container:connect_signal("mouse::leave", function()
    if containing_wibox then
      containing_wibox.cursor = saved_cursor
      containing_wibox.is_moused_over = false
      containing_wibox = nil
    end
  end)

  container:connect_signal("mouse::enter", set_alpha_cb("11"))
  container:connect_signal("mouse::leave", set_alpha_cb("00"))
  container:connect_signal("button::press", set_alpha_cb("22"))
  container:connect_signal("button::release", set_alpha_cb("11"))

  return container
end

return build
