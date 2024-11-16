local GLib = require("lgi").GLib
local gstring = require("gears.string")
local notifs = require("util.notifs")
local spawn = require("util.spawn")
local strings = require("util.strings")

local user = GLib.get_user_name()
spawn.async_success({ "last", "-n2", "--", user }, function(stdout)
  local lines = strings.split(stdout, "\n")
  local lastlog = lines[2]
  if not user or not gstring.startswith(lastlog, user) then
    lastlog = lines[1] -- in case there's only one line
  end
  if not lastlog then return end
  local timedate = lastlog:match("^%S+%s+%S+%s+(.*)")
  timedate = timedate:match("(.*)%s%-.+") or timedate -- Attempt to remove log out
  if not timedate then return notifs.error("Could not parse last output") end
  return notifs.normal("Last login: " .. tostring(timedate))
end)
