local Gio = require("lgi").Gio
local new_file_for_path = require("util.file.new_file_for_path")
---Gets the file type of a file
---@generic Path :string
---@param path Path
---@param cb fun(type?: GFileType, err?: GError, path: Path): any
---@param types? string[]
local function query_file_type_async(path, cb, types)
  local attr = table.concat({ Gio.FILE_ATTRIBUTE_STANDARD_TYPE, table.unpack(types or {}) }, ",")
  return new_file_for_path(path):query_info_async(attr, 0, 0, nil, function(file, task)
    local info, err = file:query_info_finish(task)
    if not info then return cb(nil, err, path) end
    local ftype = info:get_file_type()
    return cb(ftype, nil, path)
  end)
end
return query_file_type_async
