local gstring = require("gears.string")
local gtable = require("gears.table")
local M = {}
---@nodiscard
---@param lines (string?)[]
---@return string
function M.line2str(lines)
  return table.concat(gtable.from_sparse(lines), "\n")
end
---@nodiscard
---@param str string
---@return string[]
function M.str2line(str)
  return gstring.split(str, "\n")
end
return M
