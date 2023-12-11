---@param file string|GFile
---@return string
local function get_filepath(file)
  if type(file) == "string" then return file end
  return assert(file:get_path())
end

return get_filepath
