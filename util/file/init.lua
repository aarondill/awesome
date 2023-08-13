local M = {
  read_async = require("util.file.read_async"),
  write_async = require("util.file.write_async"),
  append_async = require("util.file.append_async"),
  basename = require("util.file.basename"),
  exists = require("util.file.exists"),
  scan_directory = require("util.file.scan_directory"),
  list_directory = require("util.file.list_directory"),
}
return setmetatable(M, { -- Just incase I forget to update the init table
  __index = function(_, key)
    local ok, mod = pcall(require, "util.file." .. key)
    if not ok then return nil end
    return mod
  end,
})
