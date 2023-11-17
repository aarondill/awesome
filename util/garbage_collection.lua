local M = {}
---@class (exact) garbageCollectionIndex
---@field date number
---@field last_warn number
---@field from string

---@class save_from_garbage_collection
---This array is in module scope, allowing values to be placed inside of it, without worrying they will be garbage collected
---Be *CERTAIN* to clear the values when you are done with them. This can and will being a memory leak otherwise.
---@private
---@type table<garbageCollectionIndex, unknown>
local _save_from_garbage_collection = {}

---Keep a value from being garbage collected until release() is called
---@param to_save any the value to save - any non-nil value can be saved.
---@return unknown index the value to pass to release to release the value
function M.save(to_save)
  local w = debug.getinfo(2, "S") -- Caller
  ---@type garbageCollectionIndex
  local index = {
    from = w.short_src .. ":" .. w.linedefined,
    date = os.time(),
    last_warn = os.time(),
  } -- Use a table as the index, as all tables are unique
  --- Store the content in the table
  _save_from_garbage_collection[index] = to_save
  return index
end
---Allow a previously saved value to be garbage collected
---@param index unknown The value previously returned by a call to save()
---@return boolean success true if the value was released successfully, false otherwise or if improper values were provided
function M.release(index)
  if _save_from_garbage_collection[index] == nil then return false end
  _save_from_garbage_collection[index] = nil
  return true
end

_G.garbagecollectionsavetimer = require("gears.timer").new({
  timeout = 30,
  autostart = true,
  callback = function()
    local notifs = require("util.notifs")
    for index, _ in pairs(_save_from_garbage_collection) do
      if os.difftime(os.time(), index.last_warn) > 60 * 5 then
        local diff = os.difftime(os.time(), index.date)

        local msg = table.concat({
          ("value from has been stored for %.1f minutes."):format(diff / 60),
          "This is probably a bug.",
          ("The value is from '%s'"):format(index.from),
        }, "\n")
        notifs.warn(msg, { title = "Value left in garbage collection array" })
      end
    end
    return true
  end,
})

return M
