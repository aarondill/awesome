---@class save_from_garbage_collection
---This array is in module scope, allowing values to be placed inside of it, without worrying they will be garbage collected
---Be *CERTAIN* to clear the values when you are done with them. This can and will being a memory leak otherwise.
---@type any[]
---@private
local _save_from_garbage_collection = {}

---Keep a value from being garbage collected until release() is called
---@param to_save any the value to save - any non-nil value can be saved.
---@return unknown index the value to pass to release to release the value
local function save(to_save)
  local index = {} -- Use a table as the index, as all tables are unique
  --- Store the content in the table
  _save_from_garbage_collection[index] = to_save
  return index
end
---Allow a previously saved value to be garbage collected
---@param index unknown The value previously returned by a call to save()
---@return boolean success true if the value was released successfully, false otherwise or if improper values were provided
local function release(index)
  if _save_from_garbage_collection[index] == nil then return false end
  _save_from_garbage_collection[index] = nil
  return true
end

local garbage_collection = {
  save = save,
  release = release,
}
return garbage_collection
