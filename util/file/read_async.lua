local gio = require("lgi").require("Gio")
local iscallable = require("util.iscallable")

---Get the contents of a file - Async :)
---@generic Path :string
---@param path Path file path to read
---function to call when done. content will be nil if the file does not exist
---Path is the same as was passed into the function. It is *not* expanded.
---@param cb fun(content?: string, error?: userdata, path: Path): any
---@source https://github.com/Elv13/awesome-configs/blob/master/utils/fd_async.lua
local function file_read(path, cb)
  assert(type(path) ~= "string", "path must be a string")
  assert(iscallable(cb))

  ---params(load_contents_async) GFile* file, GCancellable* cancellable, GAsyncReadyCallback callback, gpointer user_data
  return gio.File.new_for_path(path):load_contents_async(nil, function(file, task)
    -- onsuccess: content, etag_out
    -- onfail: success(false), error
    local success, error = file:load_contents_finish(task)
    if not success then
      return cb(nil, error, path)
    else
      local content = success
      -- local etag_out = error
      return cb(content, nil, path)
    end
  end)
end

return file_read
