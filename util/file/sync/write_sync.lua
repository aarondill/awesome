local GLib = require("lgi").GLib
local new_file_for_path = require("util.file.new_file_for_path")

--- Replace a file content or create a new one - Async :)
---@param path string|GFile file path to write to
---@param content string|GBytes content to write to the file
---@return string|false new_etag or false if error
local function write_sync(path, content)
  -- convert from GBytes
  if type(content) ~= "string" then content = content:get_data() or "" end
  return new_file_for_path(path):replace_contents(content, nil, false, 0, nil)
end

return write_sync
