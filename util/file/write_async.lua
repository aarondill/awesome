local gio = require("lgi").Gio
local garbage_collection = require("util.garbage_collection")

--- Replace a file content or create a new one - Async :)
---@param path string file path to write to
---@param content string content to write to the file
---@param cb fun()? function to call when done.
---@source https://github.com/Elv13/awesome-configs/blob/master/utils/fd_async.lua
local function file_write(path, content, cb)
  if type(path) ~= "string" or type(content) ~= "string" then error("path and content must be strings", 2) end
  local index = garbage_collection.save(content)

  ---params(replace_contents_async): string contents, string etag, boolean make_backup, GFileCreateFlags flags, GCancellable* cancellable, GAsyncReadyCallback callback, gpointer user_data
  --- NOTE: This function does not copy `content`, so we must protect it from being garbage-collected (resulting in garbage being written to disk)
  gio.File.new_for_path(path):replace_contents_async(content, nil, false, 0, nil, function(file, task)
    --- Finish the write operation and close the file(?)
    file:replace_contents_finish(task)

    --- Clear the content to allow garbage collection - Avoid a memory leak
    garbage_collection.release(index)
    index = nil
    collectgarbage("collect")
    if type(cb) == "function" then cb() end
    collectgarbage("collect")
  end)
end

return file_write