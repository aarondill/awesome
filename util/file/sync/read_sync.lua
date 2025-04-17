local new_file_for_path = require("util.file.new_file_for_path")

---Get the contents of a file
---WARNING: This is synchronous! This *will* block the main thread!
---@generic Path :string|GFile
---@param path Path file path to read
---function to call when done. content will be nil if the file does not exist
---Path is the same as was passed into the function. It is *not* expanded.
---@return string? content
---@return GError? error
---@return Path? path
local function file_read(path)
  -- onsuccess: content, etag_out
  -- onfail: success(false), error
  local content, error = new_file_for_path(path):load_contents(nil)
  if not content then
    assert(type(error) == "userdata", "error is not a GError")
    return nil, error, path
  end
  return content, nil, path
end

return file_read
