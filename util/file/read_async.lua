local gio = require("lgi").require("Gio")

---Get the contents of a file - Async :)
---@generic Path :string
---@param path Path file path to read
---@param cb fun(content?: string, error?: userdata, path: Path) function to call when done. content will be nil if the file does not exist
---@source https://github.com/Elv13/awesome-configs/blob/master/utils/fd_async.lua
local function file_read(path, cb)
  if type(path) ~= "string" then error("path must be a string", 2) end
  if type(cb) ~= "function" then error("the callback is required") end

  ---params(load_contents_async) GFile* file, GCancellable* cancellable, GAsyncReadyCallback callback, gpointer user_data
  gio.File.new_for_path(path):load_contents_async(nil, function(file, task)
    -- onsuccess: content, etag_out
    -- onfail: success(false), error
    local success, error = file:load_contents_finish(task)
    if not success then
      cb(nil, error, path)
    else
      local content = success
      -- local etag_out = error
      cb(content, nil, path)
    end
  end)
end

return file_read
