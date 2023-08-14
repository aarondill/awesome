---@param str string
---@return string
local function escape_xml(str)
  str = string.gsub(str, "&", "&amp;")
  str = string.gsub(str, "<", "&lt;")
  str = string.gsub(str, ">", "&gt;")
  str = string.gsub(str, "'", "&apos;")
  str = string.gsub(str, '"', "&quot;")

  return str
end

return escape_xml
