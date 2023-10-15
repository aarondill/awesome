local gio = require("lgi").require("Gio")
local gtable = require("gears.table")
---@alias filter_func  fun(file: table): boolean?, boolean?
---@class scan_directory_args
---@field attributes? string[] see: https://docs.gtk.org/gio/method.File.enumerate_children.html
---The maximum number of results to return. Applied after filtering.
---Note: when operating on local files, returned files will be sorted by inode number.
---Use caution when using this, as you likely will *not* get the results you expect, unless coupled with a filter.
---@field max? integer
---@field block_size? integer the number of results to get on each call. Usually not needed. (default: 128)
---Return true to include the result, false or nil to exclude it. Return false as the second argument to stop iterating.
---Note: this will *only* be called on files that have at least one (given) attribute set.
---@field filter? filter_func

local function enumerate_handler_finish(content, cb, ret)
  content:close_async(0, nil, function(gfile_close, task_close)
    return gfile_close:close_finish(task_close)
  end)
  return cb(ret, nil)
end
local function default_filter() ---@type filter_func
  return true, true
end
---@param cb fun(info?: table, error?: userdata) The function to call when done. If failed, it will be called with nil
---@param args scan_directory_args
---@param ret table? used for recursive calls
local function enumerate_handler(content, args, cb, ret)
  ret = ret or {} -- create if not passed
  -- if max is specified, block size should not be greater than max
  local block_size = args.max and math.min(args.block_size or 128, args.max) or args.block_size
  local filter = args.filter or default_filter -- User defined filter or else default true filter
  if block_size <= 0 then -- next request would not return anything
    -- max files have been hit -- or invalid input
    return enumerate_handler_finish(content, cb, ret)
  end
  return content:next_files_async(block_size, 0, nil, function(file_enum, task2)
    local file_list = file_enum:next_files_finish(task2)
    --- Number of files included in this iteration.
    --- Used to calculate when we hit the max number of files desired.
    --- This should not be incremeneted if the filter returns false.
    local included_files = 0
    for _, file in ipairs(file_list) do
      local ret_attr, has_attr = {}, false
      for _, v in ipairs(args.attributes) do
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
      if has_attr then
        local include, continue = filter(ret_attr)
        if include then -- Should include this in the return!
          ret[#ret + 1] = ret_attr
          included_files = included_files + 1
        end
        if continue == false then -- Stop *now*. Don't finish looping files (even the ones we already collected!)
          return enumerate_handler_finish(content, cb, ret)
        end
      end
    end

    if #file_list < block_size then -- no more files left (or error)
      return enumerate_handler_finish(content, cb, ret)
    end

    assert(included_files >= 0, "Negative number of included files. WTF?")
    if args.max and included_files > 0 then -- Skip assignment if num-0
      -- remove files already found, this will be evaluated next time
      args.max = args.max - included_files
    end
    return enumerate_handler(content, args, cb, ret)
  end)
end

---Scan a directory content
---This function return multiple file sttributes, see:

---https://developer.gnome.org/gio/stable/GFileInfo.html#G-FILE-ATTRIBUTE-STANDARD-TYPE:CAPS
---for details. The list of requestion attributes can be passed in the args.attributes
---argument. The default only return the file name. Use list_directory for a more
---basic file list.
---The most useful attributes are: FILE_ATTRIBUTE_STANDARD_NAME and FILE_ATTRIBUTE_STANDARD_TYPE
-- NOTE: when operating on local files, returned files will be sorted by inode number
---
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
  args = args and gtable.clone(args, false) or {} ---@type scan_directory_args
  assert(type(path) == "string", "path must be a string")
  assert(type(args) == "table", "args must be a table")
  assert(type(cb) == "function", "callback must be a function")
  assert(type(args.attributes or {}) == "table", "attributes must be a table")
  assert(args.max or 1 > 0, "max must be greater than 0")
  assert(args.block_size or 1 > 0, "block size must be greater than 0")
  assert(type(args.filter or function() end) == "function", "filter must be a function")
  args.attributes = args.attributes or { "FILE_ATTRIBUTE_STANDARD_NAME" }
  args.block_size = args.block_size or 128
  -- if max is specified, block size should not be greater than max
  if args.max then args.block_size = math.min(args.block_size, args.max) end

  local attr_str = ""
  for _, v in ipairs(args.attributes) do
    local gio_attr = assert(gio[v], ("invalid attribute: %s"):format(v))
    if gio_attr then attr_str = attr_str .. gio_attr .. "," end
  end

  gio.File.new_for_path(path):enumerate_children_async(attr_str, 0, 0, nil, function(gfile, gtask)
    local content, error = gfile:enumerate_children_finish(gtask)
    if not content then return cb(nil, error) end
    return enumerate_handler(content, args, cb)
  end)
end
return scan_directory
