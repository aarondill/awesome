local notifs = require("util.notifs")
local spawn = require("util.spawn")
local strings = require("util.strings")
local MESSAGE_FORMAT = "%d updates can be applied immediately."

local updates = 0

local left = 0
local wrap = function(f)
  return function(...)
    local count = f(...)
    updates = updates + (count or 0)
    left = left - 1
    if left > 0 then return end
    return notifs.info(MESSAGE_FORMAT:format(updates))
  end
end
local async = function(cmd, cb, opts)
  left = left + 1 --- Race conditions! But, who cares? Not me :)
  local suc = spawn.async(cmd, wrap(cb), opts)
  if not suc then left = left - 1 end
end

async({ "/usr/lib/update-notifier/apt-check" }, function(_, stderr, reason, code)
  if not spawn.is_normal_exit(reason, code) then return end
  local count = tonumber(stderr:match("(%d+);"), 10)
  if not count or count <= 0 then return end
  return count
end)
async({ "snap", "refresh", "--list" }, function(stdout, _, reason, code)
  if not spawn.is_normal_exit(reason, code) then return end
  local lines = strings.count(stdout, "\n")
  if lines <= 0 then return end
  local count = lines - 1 -- note: remove header line
  return count
end)
---Do checks for other systems (ie: pacman, zipper, etc)
