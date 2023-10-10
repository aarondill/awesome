---From https://stackoverflow.com/a/58795138
---@param x unknown?
local function iscallable(x)
  if type(x) == "function" then return true end
  if type(x) ~= "table" then return false end
  if not debug then return false end -- Give up.

  local mt = debug.getmetatable(x)
  return type(mt) == "table" and type(mt.__call) == "function"
end

return iscallable
