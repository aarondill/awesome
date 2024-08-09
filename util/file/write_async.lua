local GLib = require("lgi.GLib")
local new_file_for_path = require("util.file.new_file_for_path")

--- Replace a file content or create a new one - Async :)
---@param path string file path to write to
---@param content string|GBytes content to write to the file
---@param cb fun(error?: userdata)? function to call when done.
---@source https://github.com/Elv13/awesome-configs/blob/master/utils/fd_async.lua
local function file_write(path, content, cb)
  if type(path) ~= "string" or type(content) ~= "string" then error("path and content must be strings", 2) end
  cb = cb or function() end

  if type(content) == "string" then -- convert to GBytes
    content = GLib.Bytes.new(content)
  end
  ---params(replace_contents_async): string contents, string etag, boolean make_backup, GFileCreateFlags flags, GCancellable* cancellable, GAsyncReadyCallback callback, gpointer user_data
  new_file_for_path(path):replace_contents_bytes_async(content, nil, false, 0, nil, function(file, task)
    --- Finish the write operation and close the file(?)
    local suc, error = file:replace_contents_finish(task)
    if not suc then
      assert(type(error) == "userdata", "Non-userdata error returned from replace_contents_finish!")
      return cb(error)
    end
    return cb(nil)
  end)
end

return file_write
