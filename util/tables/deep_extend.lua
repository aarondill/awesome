local require = require("util.rel_require")
--
local isarray = require(..., "is_array")
local stream = require("stream")

--- We only merge empty tables or tables that are not an array (indexed by integers)
local function can_merge(v) return type(v) == "table" and (next(v) == nil or not isarray(v)) end

--- Adapted from vim.tbl_deep_extend in NeoVim source code
--- Merges recursively two or more tables.
---
---@generic T1: table
---@generic T2: table
---@param behavior -- Decides what to do if a key is found in more than one map:
---      |"error": raise an error
---      |"keep":  use value from the leftmost map
---      |"force": use value from the rightmost map
---@param ... T2 Two or more tables
---@return T1|T2 table Merged table
local function tbl_deep_extend(behavior, ...)
  if behavior ~= "error" and behavior ~= "keep" and behavior ~= "force" then error("invalid behavior", 1) end
  if select("#", ...) < 2 then error("wrong number of arguments", 1) end
  local ret = {} --- @type table<any,any>
  for i = 1, select("#", ...) do
    local tbl = select(i, ...)
    if not tbl then goto continue end
    if type(tbl) ~= "table" then error("argument #" .. i .. " is not a table", 2) end
    for k, v in pairs(tbl) do
      if can_merge(v) and can_merge(ret[k]) then
        ret[k] = tbl_deep_extend(behavior, ret[k], v)
      elseif behavior ~= "force" and ret[k] ~= nil then
        if behavior == "error" then error("key found in more than one map: " .. k) end -- Else behavior is "keep".
      else
        ret[k] = v
      end
    end
    ::continue::
  end
  return ret
end

return tbl_deep_extend
