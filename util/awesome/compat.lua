local capi = require("capi")
---Creates a function which returns val
---@generic R
---@param val R
---@return fun():R
local function ret_val(val)
  return function() return val end
end
---Not a factory!
local function ret_arg(val) return val end
---@generic T
---t is just used to handle the return signature
---@return fun(o: table, t?: T): T
local function lazy_access(key)
  if key == nil then return ret_val(nil) end
  ---@diagnostic disable-next-line :unused-local
  return function(o, t) return o[key] end
end
---@generic T
---@return fun(o: table, val: T):T
local function lazy_set(key)
  if key == nil then return ret_arg end
  return function(o, val)
    o[key] = val
    return val
  end
end

---Returns true if the current version is <= the given version
---Returns false if the current version is greater than the given version
---@param v string?
---@return boolean
local function vers_cmp(v)
  if not v then return false end
  return capi.awesome.version <= v -- awesome.version is a string
end
---@generic A,B
---return a if v or b
---If current version <= v then returns a, else b
---@param v string
---@param a A
---@param b B
---@return A|B
local function vers(v, a, b)
  if vers_cmp(v) then
    return a
  else
    return b
  end
end

---Creates a function which returns val
---@generic T
---@param t T
---@return T
local function verify_functions(t)
  for k, v in pairs(t) do
    if type(v) == "table" then
      verify_functions(v)
    elseif k:find("^get_.*$") then -- starts with get_ and is function
      assert(type(v) == "function", ("Expected type function at 'util.compat[%s]', got '%s'"):format(k, type(v)))
    end
  end
  return t
end

local M = verify_functions({
  signal = {
    manage = vers("v4.3", "manage", "request::manage"),
    unmanage = vers("v4.3", "unmanage", "request::unmanage"),
  },
  widget = {
    halign = vers("v4.3", "align", "halign"),
    set_halign = function(self, o, val)
      o[self.halign] = val
      return o
    end,
    ---@param args table<'screen', screen>
    get_layoutbox_args = function(args) return vers("v4.3", args.screen, args) end,
    set_border_width = lazy_set(vers("v4.3", "shape_border_width", "border_width")),
    get_border_width = lazy_access(vers("v4.3", "shape_border_width", "border_width")),
    set_border_color = lazy_set(vers("v4.3", "shape_border_color", "border_color")),
    get_border_color = lazy_access(vers("v4.3", "shape_border_color", "border_color")),
  },
  beautiful = {
    get_border_focus = lazy_access(vers("v4.3", "border_focus", "border_color_active")),
    set_border_focus = lazy_set(vers("v4.3", "border_focus", "border_color_active")),
    get_border_normal = lazy_access(vers("v4.3", "border_normal", "border_color_normal")),
    set_border_normal = lazy_set(vers("v4.3", "border_normal", "border_color_normal")),
  },
  rules = {
    --- Awesome 4.3 and below (awful.rules) didn't check exclude shape in it's function check
    --- Due to this, you had to wrap shape functions in an function that just returns the value
    --- In Awesome-git, (ruled) specifically excludes `shape` and so this check is no longer necessary (or functional)
    ---@generic F :function
    ---@param f F
    ---@return F|fun():F
    shape_function = function(f) return vers("v4.3", ret_val(f), f) end,
  },
})

return M
