---Replace all instances of from with to in the widget provided
---Recursive! could have bad performance on large widgets
---@param widget table the widget to replace child of
---@param from table what to remove
---@param to table what to replace with
local function replace_in_widget(widget, from, to)
  -- Likely passed wrong thing
  if widget.widget then
    widget = widget.widget
  end

  local seen = {}
  for _, c in ipairs(widget.children) do
    -- If nil or already seen (avoid infinite loop)
    if not c or seen[c] then
      goto continue
    end

    seen[c] = true

    if c.children then
      replace_in_widget(c, from, to)
    end

    if type(c.replace_widget) == "function" then
      -- Replace "all" instances of the placeholder with the real thing
      c:replace_widget(from, to, true)
    end

    ::continue::
  end
end
return replace_in_widget
