---@param bool boolean
---@param x unknown?
---@return boolean
---@return string?
local function failed(bool, x)
  if bool then return true end
  return false, "expected function got type " .. type(x) -- Return string for assertions
end

---From https://stackoverflow.com/a/58795138
---@param x unknown?
---@param permit_nil boolean? default: false
---@return boolean callable
---@return string? err For convenience with assert()
local function iscallable(x, permit_nil)
  permit_nil = not not permit_nil
  if x == nil then return failed(permit_nil, x) end
  if type(x) == "function" then return true end
  if type(x) ~= "table" then return failed(false, x) end
  local ok, mt = pcall(getmetatable, x)
  if not ok or (mt and type(mt) ~= "table") then -- Errored or returned a non-table
    if not debug then return failed(false, x) end -- Give up.
    mt = debug.getmetatable(x)
  end
  local callable = type(mt) == "table" and type(mt.__call) == "function"
  return failed(callable, x)
end

return iscallable
