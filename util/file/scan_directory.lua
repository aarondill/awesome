local gio = require("lgi").require("Gio")
---@class scan_directory_args
---@field attributes string[]?

---Scan a directory content
---This function return multiple file sttributes, see:
---https://developer.gnome.org/gio/stable/GFileInfo.html#G-FILE-ATTRIBUTE-STANDARD-TYPE:CAPS
---for details. The list of requestion attributes can be passed in the args.attributes
---argument. The default only return the file name. Use gears.async.directory.list for a more
---basic file list.
---@param path string the directory to scan
---@param args scan_directory_args? a table describing the list of requestion attributes
---@param cb fun(info?: table, error?: userdata) The function to call when done. If failed, it will be called with nil
---@overload fun(path: string, cb: fun(info?: table))
---@source https://github.com/Elv13/awesome-configs/blob/master/utils/fd_async.lua
local function scan_directory(path, args, cb)
  if not path then return end
  if type(args) == "function" and cb == nil then
    cb, args = args, nil
  end
  args = args or {}
  assert(type(path) == "string", "path must be a string")
  assert(type(args) == "table", "args must be a table")
  assert(type(cb) == "function", "callback must be a function")

  local attr_str = ""
  if args.attributes then
    for _, v in ipairs(args.attributes or { "FILE_ATTRIBUTE_STANDARD_NAME" }) do
      attr_str = attr_str .. gio[v] .. ","
    end
  end

  gio.File.new_for_path(path):enumerate_children_async(attr_str, 0, 0, nil, function(gfile, task)
    local content, error = gfile:enumerate_children_finish(task)
    if not content then return cb(nil, error) end
    content:next_files_async(99999, 0, nil, function(file_enum, task2)
      local ret = {}
      local all_files = file_enum:next_files_finish(task2)
      for _, file in ipairs(all_files) do
        local ret_attr, has_attr = {}, false
        for _, v in ipairs(args.attributes or { "FILE_ATTRIBUTE_STANDARD_NAME" }) do
          local attr, val = gio[v], nil
          local attr_type = file:get_attribute_type(attr)
          if attr_type == "OBJECT" then
            val = file:get_attribute_object(attr)
          else
            val = file:get_attribute_as_string(attr)
          end
          if val then
            has_attr = true
            ret_attr[v] = val
          end
        end
        if has_attr then ret[#ret + 1] = ret_attr end
      end
      content:close_async(0, nil)
      return cb(ret, nil)
    end)
  end)
end
return scan_directory
