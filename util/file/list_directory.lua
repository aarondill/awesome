local assertions = require("util.types.assertions")
local gtable = require("gears.table")
local join = require("util.path.join")
local require = require("util.rel_require")
local FILE_NAME_PROP = "FILE_ATTRIBUTE_STANDARD_NAME"

local scan_directory = require(..., "scan_directory") ---@module "util.file.scan_directory"
---@class list_directory_args :scan_directory_args
---@field match string? a lua pattern to match against the file names
---@field full_path boolean? Whether to return the full path or just the file name [default: false]

---@alias list_directory_cb fun(names?: string[], error?: userdata): any?
--- Return a file list (name only)
---@param path string
---@param args list_directory_args?
---@param cb list_directory_cb
---@overload fun(path: string, cb: list_directory_cb)
---@source https://github.com/Elv13/awesome-configs/blob/master/utils/fd_async.lua
local function list_directory(path, args, cb)
  if not path then return end
  if type(args) == "function" and cb == nil then
    cb, args = args, nil
  end
  args = args and gtable.clone(args) or {} ---@type list_directory_args
  assertions.type(args, "table", "args")
  assertions.type(args.match, { "string", "nil" }, "args.match")

  local match, full_path = args.match, args.full_path
  args.match, args.full_path = nil, nil -- don't pass to scan_directory

  args.filter = match -- if a match is specified, filter based on it.
    and function(file)
      local name = file[FILE_NAME_PROP] ---@type string
      return name:match(match) ~= nil -- include only if filename matches pattern
    end
  args.attributes = { FILE_NAME_PROP } -- override user provided

  return scan_directory(path, args, function(files, err)
    if files == nil then return cb(nil, err) end
    local names = {} ---@type string[]
    for k, v in ipairs(files) do
      local name = v[FILE_NAME_PROP]
      assert(type(name) == "string", "File name is not a string")
      -- Return full path if specified
      names[k] = full_path and join(path, name) or name
    end
    return cb(names, nil)
  end)
end

return list_directory
