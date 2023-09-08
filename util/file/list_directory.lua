local gtable = require("gears.table")
local require = require("util.rel_require")

local scan_directory = require(..., "scan_directory") ---@module "util.file.scan_directory"
---@class list_directory_args :scan_directory_args
---@field match string? a lua pattern to match against the file names

---@alias list_directory_cb fun(names?: string[], error?: userdata)
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
  args = args and gtable.clone(args) or {}
  assert(type(args) == "table", "args must be a table")
  assert(type(args.match or "") == "string", "args.match must be a string")
  args.attributes = { "FILE_ATTRIBUTE_STANDARD_NAME" } -- override user provided
  scan_directory(path, args, function(contents, error)
    if not contents then return cb(contents, error) end
    local ret = {}
    for _, v in ipairs(contents) do
      ---@type string
      local name = v["FILE_ATTRIBUTE_STANDARD_NAME"]
      if (not args.match) or name:match(args.match) ~= nil then
        ret[#ret + 1] = name -- handle match pattern
      end
    end
    cb(ret, error)
  end)
end

return list_directory
