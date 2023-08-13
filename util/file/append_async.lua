local gio = require("lgi").Gio
local garbage_collection = require("util.garbage_collection")

-- Write to a stream
local function outputstream_write(stream, content, cb)
  ---params(stream:write_async) GOutputStream* stream, void* buffer, gsize count, int io_priority, GCancellable* cancellable, GAsyncReadyCallback callback, gpointer user_data
  stream:write_async(content, content:len(), nil, function(file, task)
    local _ = file:write_finish(task)
    if type(cb) == "function" then cb() end
  end)
end

--- Replace a file content or create a new one - Async :)
---@param path string file path to append to
---@param content string content to append to the file
---@param cb fun()? function to call when done.
---@source https://github.com/Elv13/awesome-configs/blob/master/utils/fd_async.lua
local function file_append(path, content, cb)
  if type(path) ~= "string" or type(content) ~= "string" then error("path and content must be strings", 2) end
  --- Store the content in the global array
  local index = garbage_collection.save(content)
  local io_priority = 0

  ---params(file:g_file_append_to_async): GFile* file, GFileCreateFlags flags, int io_priority, GCancellable* cancellable, GAsyncReadyCallback callback, gpointer user_data
  -- Append to file
  gio.File.new_for_path(path):append_to_async({}, io_priority, nil, function(file, task)
    local stream = file:append_to_finish(task)
    outputstream_write(stream, content, function()
      stream:close()
      if type(cb) == "function" then cb() end
      garbage_collection.release(index)
      index = nil
    end)
  end, 0)
end

return file_append
