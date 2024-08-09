local Gio = require("lgi.Gio")
local new_file_for_path = require("util.file.new_file_for_path")
local path = require("util.path")
---@param filepath string|GFile
---@param fn fun(pathname: string, name: string, type: GFileType)
---@return true?, (GError|string)?
local function ls(filepath, fn)
  local attributes = { Gio.FILE_ATTRIBUTE_STANDARD_NAME, Gio.FILE_ATTRIBUTE_STANDARD_TYPE }
  local attr_str = table.concat(attributes, ",")

  local rootfile = new_file_for_path(filepath)
  local rootpath = rootfile:get_path()
  if not rootpath or not rootfile:query_exists() then return nil, "No such file or directory" end

  local it, enum_err = rootfile:enumerate_children(attr_str, 0)
  if not it then return nil, enum_err end
  local fileinfo = it:next_file()
  while fileinfo do
    local type, name = fileinfo:get_file_type(), fileinfo:get_name()
    local pathname = path.join(rootpath, name)
    fn(pathname, name, type)
    fileinfo = it:next_file()
  end
  it:close_async(0)
  return true, nil
end
return ls
