---@param t any
local function isarray(t) ---@return boolean
  if type(t) ~= "table" then return false end
  for k, _ in pairs(t) do
    -- Check if the number k is an integer
    if type(k) ~= "number" or k ~= math.floor(k) then return false end
  end
  return true
end
return isarray
