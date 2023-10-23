local find_home = require("util.find_home")
local notifs = require("util.notifs")
local read_async = require("util.file.read_async")

local function extensions(path, exts)
  local ret = { path }
  for _, ext in ipairs(exts) do
    table.insert(ret, ("%s.%s"):format(path, ext))
  end
  return ret
end
local home_reminder = find_home("./reminder")
local paths = extensions(home_reminder, { "txt", "md" })
local index = 1

local function handler(content, _, path)
  if not content then -- Repeat until we find one.
    index = index + 1 -- Try the next one.
    if not paths[index] then return end
    return read_async(paths[index], handler)
  end

  return notifs.info(
    content:gsub("^\n*", ""):gsub("\n*$", ""):gsub("\n\n\n", "\n\n"),
    { title = ("Reminder (%s)"):format(path) }
  )
end

return read_async(paths[index], handler)
