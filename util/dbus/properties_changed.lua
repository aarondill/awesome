local gtable = require("gears.table")
local require = require("util.rel_require")
local subscribe_signal = require(..., "subscribe_signal") ---@module 'util.dbus.subscribe_signal'
local tables = require("util.tables")

local M = {}
---@return string name
---@return table<string, unknown> changed
---@return string[] invalidated
function M.parse_properties_changed(params)
  -- STRING interface_name,
  -- ARRAY of DICT_ENTRY<STRING,VARIANT> changed_properties,
  -- ARRAY<STRING> invalidated_properties
  assert(params.type == "(sa{sv}as)")
  local name = params:get_child_value(0).value ---@type string
  assert(type(name) == "string")

  -- This mess is needed to unwrap such a complicated Varient. these are terrible.
  local changed = {} ---@type table<string, unknown>
  local changed_varient_arr = params:get_child_value(1)
  for _, changed_varient in ipairs(changed_varient_arr) do
    local k = changed_varient[1]
    assert(type(k) == "string")
    local v = changed_varient[2].value ---@type unknown
    changed[k] = v
  end

  local invalidated_varient_arr = params:get_child_value(2)
  local invalidated = {} ---@type string[]
  for _, varient in ipairs(invalidated_varient_arr) do
    local v = varient[1]
    assert(type(v) == "string")
    invalidated[#invalidated + 1] = v
  end

  return name, changed, invalidated
end
M.parse = M.parse_properties_changed

---@param sender string
---@param object string
---@param cb fun(name: string, changed: table<string, unknown>, invalidated: string[]): any?
---@param properties? string|string[] if given, callback will only be called when one of these are changed
---@return SubscribeID
function M.subscribe(sender, object, cb, properties)
  if type(properties) == "string" then properties = { properties } end
  return subscribe_signal.subscribe({
    sender = sender,
    object = object,
    interface = "org.freedesktop.DBus.Properties",
    member = "PropertiesChanged",
    callback = function(_bus, _sender, _object, _interface, _signal, params)
      local name, changed, invalidated = M.parse_properties_changed(params)
      if properties then
        ---Filter only changed properties within the requested properties
        local new_changed = {}
        for _, p in ipairs(properties) do
          if changed[p] ~= nil then new_changed[p] = changed[p] end
        end
        changed = new_changed
        ---if none of the requested properties have changed, the user doesn't want a callback
        if next(changed) == nil then return end
      end
      return cb(name, changed, invalidated)
    end,
  })
end
M.unsubscribe = subscribe_signal.unsubscribe -- For symetry

return M
