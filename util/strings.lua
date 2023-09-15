local gstring = require("gears.string")
local gtable = require("gears.table")
local M = {}
---@nodiscard
---@param lines (string?)[]
---@return string
function M.line2str(lines)
  if not lines then return lines end
  if type(lines) ~= "table" then error("Expected table. Found: " .. type(lines) .. " instead.") end
  return table.concat(gtable.from_sparse(lines), "\n")
end
---@nodiscard
---@param str string
---@return string[]
function M.str2line(str)
  if not str then return str end
  if type(str) ~= "string" then error("Expected string. Found: " .. type(str) .. " instead.") end
  return gstring.split(str, "\n")
end
---Make the first letter uppercase
---@nodiscard
---@param str string
---@return string
function M.first_upper(str)
  if not str then return str end
  if type(str) ~= "string" then error("Expected string. Found: " .. type(str) .. " instead.") end
  return str:sub(1, 1):upper() .. str:sub(2)
end
---Make the first letter lowercase
---@nodiscard
---@param str string
---@return string
function M.first_lower(str)
  if not str then return str end
  if type(str) ~= "string" then error("Expected string. Found: " .. type(str) .. " instead.") end
  return str:sub(1, 1):lower() .. str:sub(2)
end
---Make the string title case
---@nodiscard
---@param str string
---@return string
function M.title_case(str)
  if not str then return str end
  if type(str) ~= "string" then error("Expected string. Found: " .. type(str) .. " instead.") end
  return str:sub(1, 1):upper() .. str:sub(2):lower():gsub("%s%l", string.upper)
end

return M
