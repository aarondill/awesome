local gio = require("lgi").Gio

--- Replace a file content or create a new one - Async :)
---@param path string file path to write to
---@param cb fun(content?: string) function to call when done. content will be nil if the file does not exist
---@source https://github.com/Elv13/awesome-configs/blob/master/utils/fd_async.lua
local function file_read(path, cb)
  if type(path) ~= "string" then error("path must be a string", 2) end
  if type(cb) ~= "function" then error("the callback is required") end

  ---params(load_contents_async) GFile* file, GCancellable* cancellable, GAsyncReadyCallback callback, gpointer user_data
  gio.File.new_for_path(path):load_contents_async(nil, function(file, task)
    local content = file:load_contents_finish(task)
    cb(content)
  end)
end

return file_read
