local GLib = require("util.lgi.GLib")
local notifs = require("util.notifs")
local spawn = require("util.spawn")
local strings = require("util.strings")

local user = GLib.get_user_name()
spawn.async({ "lastlog", "-u", user }, function(stdout, _, reason, code)
  if not spawn.is_normal_exit(reason, code) then return end
  local lastlog = strings.split(stdout, "\n")[2]
  if not lastlog then return end
  local timedate = lastlog:match("^%S+%s+%S+%s+(.*)")
  timedate = timedate:match("(.*)%s%-%d+ %d*") or timedate -- Attempt to remove time zone and year
  if not timedate then return notifs.error("Could not parse lastlog output") end
  return notifs.info("Last login: " .. tostring(timedate))
end)
