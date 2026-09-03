local assertions = require("util.types.assertions")

local tables = {}
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
function tables.clone(t, deep)
  if deep then return deepclone(t, {}) end
  local ret = {}
  for k, v in pairs(t) do
    ret[k] = v
  end
  return ret
end

---Concat all arguments into a copy of t1, returns a new table.
---@param t1 unknown[]
---@param ... unknown
---@return (unknown[]|{n: integer}) joined a new table containing the concatenation
function tables.concat(t1, ...)
  local res = tables.clone(t1)
  local tn = #res
  for n = 1, select("#", ...) do
    local arg = select(n, ...)
    res[tn + 1] = arg
    tn = tn + 1
  end
  res.n = tn
  return res
end

--- Deep compare values for equality
--- @source /usr/share/nvim/runtime/lua/vim/shared.lua
--- Tables are compared recursively unless they both provide the `eq` metamethod.
--- All other types are compared using the equality `==` operator.
---@param a any First value
---@param b any Second value
---@return boolean `true` if values are equals, else `false`
function tables.deep_equal(a, b)
  if a == b then return true end
  if type(a) ~= type(b) then return false end
  if type(a) ~= "table" then return false end
  for k, v in pairs(a) do
    if not tables.deep_equal(v, b[k]) then return false end
  end
  for k, _ in pairs(b) do
    if a[k] == nil then return false end
  end
  return true
end

---Returns a table containing elements that pass the filter
---@generic K, V
---@param t table<K, V>
---@param func fun(v: V, k: K, t: table<K, V>): boolean?
---@return table
function tables.filter(t, func)
  local res = {}
  for i, v in pairs(t) do
    if func(v, i, t) then table.insert(res, v) end
  end
  return res
end

---Returns the first element for which the function returns true
---@generic K, V
---@param t table<K, V>
---@param func fun(v: V, k: K, t: table<K, V>): boolean?
---@return V?, K?
function tables.find(t, func)
  for i, v in pairs(t) do
    if func(v, i, t) then return v, i end
  end
end

function tables.contains(t, v)
  for _, v2 in pairs(t) do
    if v == v2 then return true end
  end
  return false
end

---@param t any
function tables.isarray(t) ---@return boolean
  if type(t) ~= "table" then return false end
  for k, _ in pairs(t) do -- Check if the number k is an integer
    if type(k) ~= "number" or k ~= math.floor(k) then return false end
  end
  return true
end

--- return a new array containing the concatenation of all of its
--- parameters. Array parameters have their values shallow-copied
--- to the final array. All parameters are must be tables, or else
-- an error is thrown.
---@param ... table a set of tables to join together
---@return table joined a new table containing the concatenation
function tables.join(...)
  local t = {}
  local tn = 0
  for n = 1, select("#", ...) do
    local arg = select(n, ...)
    assertions.type(arg, "table", "argument " .. n)
    local alen = arg.n or #arg
    for i = 1, alen do
      t[tn + i] = arg[i]
    end
    tn = tn + alen
  end
  return t
end

--- We only merge empty tables or tables that are not an array (indexed by integers)
local function can_merge(v) return type(v) == "table" and (next(v) == nil or not tables.isarray(v)) end

--- Adapted from vim.tbl_deep_extend in NeoVim source code
--- Merges recursively two or more tables.
---
---@generic T1: table
---@generic T2: table
---@param behavior -- Decides what to do if a key is found in more than one map:
---      |"error": raise an error
---      |"keep":  use value from the leftmost map
---      |"force": use value from the rightmost map
---@param ... T1|T2|nil Two or more tables
---@return T1|T2 table Merged table
local function extend_recurse(recurse, behavior, ...)
  if behavior ~= "error" and behavior ~= "keep" and behavior ~= "force" then error("invalid behavior", 1) end
  if select("#", ...) < 2 then error("wrong number of arguments", 1) end
  local ret = {} --- @type table<any,any>
  for i = 1, select("#", ...) do
    local tbl = select(i, ...)
    if not tbl then goto continue end
    if type(tbl) ~= "table" then error("argument #" .. i .. " is not a table", 2) end
    for k, v in pairs(tbl) do
      if recurse and can_merge(v) and can_merge(ret[k]) then
        ret[k] = tables.tbl_deep_extend(behavior, ret[k], v)
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

--- Adapted from vim.tbl_deep_extend in NeoVim source code
--- Merges recursively two or more tables.
---
---@generic T1: table
---@generic T2: table
---@param behavior -- Decides what to do if a key is found in more than one map:
---      |"error": raise an error
---      |"keep":  use value from the leftmost map
---      |"force": use value from the rightmost map
---@param ... T1|T2|nil Two or more tables
---@return T1|T2 table Merged table
function tables.deep_extend(behavior, ...) return extend_recurse(true, behavior, ...) end

--- Merges two or more tables. Keeps the value in the rightmost table (like gtable.crush, but doesn't overwrite)
---
---@generic T1: table
---@generic T2: table
---@param ... T1|T2|nil Two or more tables
---@return T1|T2 table Merged table
function tables.extend(...) return extend_recurse(false, "force", ...) end

return tables
