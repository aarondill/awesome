local serializeTable -- Define this within the scope of type_tostring to resolve the circular dependencies

local function string_warning(warning)
  return string.format('"[%s]"', warning)
end
---@param val unknown the value to serialize
---@param skipnewlines boolean Should newlines be present in the output
---@param depth integer used for the recursive implementation. DO NOT use this.
---@return string
local function type_tostring(val, skipnewlines, depth, memoize)
  local tval = type(val)
  if tval == "nil" then
    return "nil"
  elseif tval == "table" then
    if depth > 25 then return string_warning("DEPTH LIMIT:" .. depth) end
    local tmp = ""
    tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

    for k, v in pairs(val) do
      tmp = tmp .. serializeTable(v, k, skipnewlines, depth + 1, memoize) .. "," .. (not skipnewlines and "\n" or "")
    end

    tmp = tmp .. string.rep(" ", depth) .. "}"
    return tmp
  elseif tval == "number" then
    return tostring(val)
  elseif tval == "string" then
    return string.format("%q", val)
  elseif tval == "boolean" then
    return (val and "true" or "false")
  end

  return string_warning("inserializeable datatype:" .. tval)
end
---Serialize a table into a string. Use for output
---*Could* be executed like this to get a table back: loadstring(serializeTable(...))()
---@param val unknown the value to serialize
---@param name unknown? a name to assign to the table (most useful for loadstring)
---@param skipnewlines boolean Should newlines be present in the output
---@param depth integer used for the recursive implementation. DO NOT use this.
---@param memoize fun(k: any, v: string?): string? function to manage memoization. call with just key to retreive, or with k and v to store.
---@return string
---@source https://stackoverflow.com/a/6081639
function serializeTable(val, name, skipnewlines, depth, memoize)
  local tmp = ""

  if name then
    local res = memoize(name) or type_tostring(name, skipnewlines, depth, memoize)
    memoize(name, res)
    tmp = string.rep(" ", depth)
    if depth == 0 and type(name) == "string" then
      tmp = tmp .. name .. " = "
    else
      tmp = tmp .. string.format("[%s] = ", res)
    end
  end

  local res = memoize(val) or type_tostring(val, skipnewlines, depth, memoize)
  memoize(val, res)
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
  local memoize_table = {} -- {val, count}
  local function memoize(k, v)
    if k == nil then return nil end -- Can't index with nil
    local max_count = 3
    if v == nil then
      local t = memoize_table[k]
      if not t then return end
      t[2] = t[2] + 1
      if t[2] > max_count and type(val) == "table" then return string_warning("value seen " .. t[2] .. " times") end
      return t[1]
    else
      memoize_table[k] = { v, 0 }
    end
  end
  skipnewlines = skipnewlines or false
  local res = serializeTable(val, name, skipnewlines, 0, memoize)
  memoize_table = nil
  collectgarbage("collect") -- Cleanup already_visited
  collectgarbage("collect")
  return res
end
