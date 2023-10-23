local find_home = require("util.find_home")
local notifs = require("util.notifs")
local read_async = require("util.file.read_async")

return read_async(find_home("./reminder"), function(content, _, path)
  if not content then return end
  return notifs.info(content:gsub("\n$", ""), { title = ("Reminder (%s)"):format(path) })
end)
