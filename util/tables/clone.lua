---@generic T
---@param t T
---@param seen? table<table, table>
---@return T
local function deepclone(t, seen)
  if type(t) ~= "table" then return t end
  seen = seen or {}
  if seen[t] then return seen[t] end
  local ret = {}
  seen[t] = ret
  for k, v in pairs(t) do
    ret[deepclone(k, seen)] = deepclone(v, seen)
  end
  return ret
end

--- Clone a table.
---@generic T
---@param t T  The table to clone.
---@param deep? boolean Create a deep clone? default false
---@return T clone of `t`.
local function clone(t, deep)
  if deep then return deepclone(t, {}) end
  local ret = {}
  for k, v in pairs(t) do
    ret[k] = v
  end
  return ret
end
return clone
