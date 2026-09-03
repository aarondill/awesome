--- Merges two or more tables. Keeps the value in the rightmost table (like gtable.crush, but doesn't overwrite)
---
---@generic T1: table
---@generic T2: table
---@param ... T1|T2|nil Two or more tables
---@return T1|T2 table Merged table
local function tbl_extend(...)
  if select("#", ...) < 2 then error("wrong number of arguments", 1) end
  local ret = {} --- @type table<any,any>
  for i = 1, select("#", ...) do
    local tbl = select(i, ...)
    if not tbl then goto continue end
    if type(tbl) ~= "table" then error("argument #" .. i .. " is not a table", 2) end
    for k, v in pairs(tbl) do
      ret[k] = v
    end
    ::continue::
  end
  return ret
end

return tbl_extend
