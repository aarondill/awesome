local scan_directory = require("util.file.scan_directory")
---@class list_directory_args
---@field match string? a lua pattern to match against the file names

--- Return a file list (name only)
---@param path string
---@param args list_directory_args
---@param cb fun(names: string[])
---@source https://github.com/Elv13/awesome-configs/blob/master/utils/fd_async.lua
local function list_directory(path, args, cb)
  if not path then return end
  if not cb then error("callback is required") end
  args = args or {}
  scan_directory(path, { attributes = { "FILE_ATTRIBUTE_STANDARD_NAME" } }, function(contents)
    local ret = {}
    for _, v in ipairs(contents) do
      ---@type string
      local name = v["FILE_ATTRIBUTE_STANDARD_NAME"]
      if (not args.match) or name:match(args.match) ~= nil then
        ret[#ret + 1] = name -- handle match pattern
      end
    end
    cb(ret)
  end)
end

return list_directory
