local watch = require("util.file.watch")
local function watch_directory(path, cb)
  if type(cb) ~= "function" then error("callback must be a function", 2) end
  if type(path) ~= "string" then error("path must be a string", 2) end
  watch(path, "monitor_directory", nil, cb)
end
return watch_directory
