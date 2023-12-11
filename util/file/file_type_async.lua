local Gio = require("util.lgi").Gio
---@param file GFile
---@param cb fun(type?: GFileType, err?: GError)
---@param types? string[]
local function query_file_type_async(file, cb, types)
  local attr = table.concat({ Gio.FILE_ATTRIBUTE_STANDARD_TYPE, table.unpack(types or {}) }, ",")
  return file:query_info_async(attr, 0, 0, nil, function(file2, task)
    local info, err = file2:query_info_finish(task)
    if not info then return cb(nil, err) end
    local ftype = info:get_file_type()
    return cb(ftype, nil)
  end)
end
