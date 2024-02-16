local assertions = require("util.types.assertions")
local new_file_for_path = require("util.file.new_file_for_path")

---Get the contents of a file - Async :)
---@generic Path :string
---@param path Path file path to read
---function to call when done. content will be nil if the file does not exist
---Path is the same as was passed into the function. It is *not* expanded.
---@param cb fun(content?: string, error?: userdata, path: Path): any
---@source https://github.com/Elv13/awesome-configs/blob/master/utils/fd_async.lua
local function file_read(path, cb)
  assertions.type(path, "string", "path")
  assertions.iscallable(cb, "cb")

  return new_file_for_path(path):load_contents_async(nil, function(file, task)
    -- onsuccess: content, etag_out
    -- onfail: success(false), error
    local content, error = file:load_contents_finish(task)
    -- LuaLS's type narrowing doesn't realize that this can't be a number if content is nil.
    if not content and type(error) ~= "number" then return cb(nil, error, path) end
    return cb(content, nil, path)
  end)
end

return file_read
