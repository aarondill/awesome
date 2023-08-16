local serializeTable -- Define this within the scope of type_tostring to resolve the circular dependencies

---@param val unknown the value to serialize
---@param skipnewlines boolean Should newlines be present in the output
---@param depth integer used for the recursive implementation. DO NOT use this.
---@return string
local function type_tostring(val, skipnewlines, depth, memoize)
  if depth > 25 then return "DEPTH LIMIT: " .. depth end
  if type(val) == "table" then
    local tmp = ""
    tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

    for k, v in pairs(val) do
      tmp = tmp .. serializeTable(v, k, skipnewlines, depth + 1, memoize) .. "," .. (not skipnewlines and "\n" or "")
    end

    tmp = tmp .. string.rep(" ", depth) .. "}"
    return tmp
  elseif type(val) == "number" then
    return tostring(val)
  elseif type(val) == "string" then
    return string.format("%q", val)
  elseif type(val) == "boolean" then
    return (val and "true" or "false")
  end

  return '"[inserializeable datatype:' .. type(val) .. ']"'
end
---Serialize a table into a string. Use for output
---*Could* be executed like this to get a table back: loadstring(serializeTable(...))()
---@param val unknown the value to serialize
---@param name unknown? a name to assign to the table (most useful for loadstring)
---@param skipnewlines boolean Should newlines be present in the output
---@param depth integer used for the recursive implementation. DO NOT use this.
---@return string
---@source https://stackoverflow.com/a/6081639
function serializeTable(val, name, skipnewlines, depth, memoize)
  local tmp = string.rep(" ", depth)

  if name then
    if memoize[name] then return memoize[name] end
    local res = type_tostring(name, skipnewlines, depth, memoize)
    memoize[name] = res
    if depth == 0 and type(name) == "string" then
      tmp = tmp .. name .. " = "
    else
      tmp = string.format("%s[%s] = ", tmp, res)
    end
  end

  if memoize[val] then return memoize[val] end
  local res = type_tostring(val, skipnewlines, depth, memoize)
  memoize[val] = res
  tmp = tmp .. res

  return tmp
end

-- Wrapper to ensure depth is passed correctly.

---Serialize a table into a string. Use for output
---*Could* be executed like this to get a table back: loadstring(serializeTable(...))()
---@param val table the value to serialize
---@param name string? a name to assign to the table (most useful for loadstring)
---@param skipnewlines boolean? Should newlines be present in the output
---@return string
return function(val, name, skipnewlines)
  local memoize = {}
  skipnewlines = skipnewlines or false
  local res = serializeTable(val, name, skipnewlines, 0, memoize)
  memoize = nil
  collectgarbage("collect") -- Cleanup already_visited
  collectgarbage("collect")
  return res
end
