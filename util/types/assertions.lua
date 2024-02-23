local Assert = {}

---@param t type? the received type
---@param expect type|type[]
---@param name string? the name of the value being asserted
---@param level integer?
local function type_failed(t, expect, name, level)
  level = level or 1
  t = t or "nil" -- I don't need this. but whatever.
  local expect_str = type(expect) == "table" and ("one of: " .. table.concat(expect, ", ")) or expect
  local fmt = (name and "%s: " or "%s") .. "expected type %s, but got %s." -- Hackish, but works
  local msg = fmt:format(name or "", expect_str, t) -- name or "" to ensure that the outputted name is silent!
  -- 1 is check_type_string, 2 is assert_type, 3 is caller, 4 is the function that passed the wrong type
  -- Starts at 1, so add 3 to reach correct stack level.
  -- Stack levels should be maintained even with TCO, but the stack trace will not be very helpful.
  return error(msg, level + 3)
end

---Asserts that val has the expected type. Throws an error if val is not of the expected type.
---@param val unknown?
---@param expected type|type[]
---@param name string the name of the value being asserted
---@param level integer? default: 1 Same number as passed to error(msg, level)
function Assert.type(val, expected, name, level)
  local t = type(val)
  if type(expected) == "string" then
    if t == expected then return end -- the type is valid
  elseif type(expected) == "table" then
    for _, e in pairs(expected) do
      if t == e then return end -- the type is valid
    end
  else
    return error("You *really* passed the wrong type to the type checking function... Try again.", 2) -- caller
  end

  return type_failed(t, expected, name, level)
end

---Asserts val, but returns an error like assert_type
---@param val unknown?
---@param permit_nil boolean? see iscallable(val, permit_nil)
---@param name string? the name of the value being asserted
---@param level integer? default: 1 Same number as passed to error(msg, level)
---@overload fun(val: unknown?, name: string, level: integer?)
function Assert.iscallable(val, permit_nil, name, level)
  local iscallable = require("util.types.iscallable")
  if type(permit_nil) == "string" then
    assert(not name or type(name) == "number")
    assert(not level)
    level = name
    name = permit_nil
    permit_nil = nil
  end

  if iscallable(val, permit_nil) then return end
  return type_failed(type(val), "function", name, level) -- Not *necessarily* function, but this should be clear enough
end

---Acts like assert but with the level specified
---@generic T
---@param bool T?
---@param msg string?
---@param level integer? default: 1 Same number as passed to error(msg, level)
---@return T
---@return ...
function Assert.assert(bool, msg, level, ...)
  if bool then return bool, msg, level, ... end
  level = level or 1
  msg = msg or "Assertion failed"
  error(msg, level + 1) -- Plus 1 to error on caller
end

local mt = {}
function mt:call(...) return assert(...) end
return setmetatable(Assert, mt)
