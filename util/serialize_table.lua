---Serialize a table into a string. Use for output
---*Could* be executed like this to get a table back: loadstring(serializeTable(...))()
---@param val table the value to serialize
---@param name string? a name to assign to the table (most useful for loadstring)
---@param skipnewlines boolean? Should newlines be present in the output
---@param depth integer? used for the recursive implementation. DO NOT use this.
---@return string
---@source https://stackoverflow.com/a/6081639
local function serializeTable(val, name, skipnewlines, depth)
  skipnewlines = skipnewlines or false
  depth = depth or 0

  local tmp = string.rep(" ", depth)

  if name then
    if type(name) == "string" then
      tmp = tmp .. name .. " = "
    else
      tmp = tmp .. '"[inserializeable datatype:' .. type(name) .. ']" = '
    end
  end

  if type(val) == "table" then
    tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

    for k, v in pairs(val) do
      tmp = tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
    end

    tmp = tmp .. string.rep(" ", depth) .. "}"
  elseif type(val) == "number" then
    tmp = tmp .. tostring(val)
  elseif type(val) == "string" then
    tmp = tmp .. string.format("%q", val)
  elseif type(val) == "boolean" then
    tmp = tmp .. (val and "true" or "false")
  else
    tmp = tmp .. '"[inserializeable datatype:' .. type(val) .. ']"'
  end

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
  return serializeTable(val, name, skipnewlines, 0)
end
