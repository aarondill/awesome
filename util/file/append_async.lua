local new_file_for_path = require("util.file.new_file_for_path")
local outputstream_write = require("util.file.write_outputstream")
local GLib = require("util.lgi").GLib

--- Append to a file's content - Async :)
---@param path string file path to append to
---@param content string content to append to the file
---@param cb fun(err?: userdata)? function to call when done.
---@source https://github.com/Elv13/awesome-configs/blob/master/utils/fd_async.lua
local function file_append(path, content, cb)
  if type(path) ~= "string" or type(content) ~= "string" then error("path and content must be strings", 2) end
  cb = cb or function() end

  ---params(file:g_file_append_to_async): GFile* file, GFileCreateFlags flags, int io_priority, GCancellable* cancellable, GAsyncReadyCallback callback, gpointer user_data
  -- Append to file
  return new_file_for_path(path):append_to_async({}, GLib.PRIORITY_DEFAULT, nil, function(file, task)
    local stream, append_err = file:append_to_finish(task)
    if not stream then return cb(append_err) end
    return outputstream_write(stream, content, function(write_err)
      stream:close_async()
      return cb(write_err)
    end)
  end, 0)
end

return file_append
