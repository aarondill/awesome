local gio = require("lgi").Gio

---This array is in module scope, allowing values to be placed inside of it, without worrying they will be garbage collected
---Be *CERTAIN* to clear the values when you are done with them. This can and will being a memory leak otherwise.
---@type any[]
local SAVE_FROM_GARBAGE_COLLECTION = {}
--- Used to disable lua-language-server warning about unused variables
SAVE_FROM_GARBAGE_COLLECTION = SAVE_FROM_GARBAGE_COLLECTION

--- Replace a file content or create a new one - Async :)
---@param path string file path to write to
---@param cb fun(content?: string) function to call when done.
---@source https://github.com/Elv13/awesome-configs/blob/master/utils/fd_async.lua
local function file_read(path, cb)
  if type(path) ~= "string" then error("path must be a string", 2) end
  if type(cb) ~= "function" then error("the callback is required") end

  ---params(load_contents_async) GFile* file, GCancellable* cancellable, GAsyncReadyCallback callback, gpointer user_data
  --- NOTE: This function does not copy `content`, so we must protect it from being garbage-collected (resulting in garbage being written to disk)
  local success = gio.File.new_for_path(path):load_contents_async(nil, function(file, task)
    --- Finish the write operation and close the file(?)
    local content = file:load_contents_finish(task)
    cb(content)
  end)
  if not success then cb(nil) end
end

return file_read
