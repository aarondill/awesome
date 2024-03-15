local gfile = require("gears.filesystem")
local notifs = require("util.notifs")
local path = require("util.path")
local spawn = require("util.spawn")
local strings = require("util.strings")
local tables = require("util.tables")
local MESSAGE_FORMAT = "%d updates can be applied immediately."

local updates = 0

local left = 0
local wrap = function(f)
  return function(...)
    local count = f(...)
    updates = updates + (count or 0)
    left = left - 1
    if left > 0 then return end
    if updates <= 0 then return end -- Don't bother me if there are no updates
    return notifs.info(MESSAGE_FORMAT:format(updates))
  end
end
---@param cmd CommandProvider
---Note: return the number of updates!
---@param cb fun(stdout: string, stderr: string, reason: "exit"|"signal", code: integer): integer
---@param opts SpawnOptions?
---@return integer?, string?, SpawnInfo?
local async = function(cmd, cb, opts)
  left = left + 1 --- Race conditions! But, who cares? Not me :)
  local res = table.pack(spawn.async(cmd, wrap(cb), opts))
  local suc = res[1]
  if not suc then left = left - 1 end
  return table.unpack(res, 1, res.n)
end

async({ "pacman", "-V" }, function()
  local suc = async({ "checkupdates", "--nocolor" }, function(stdout, _, reason, code)
    if not spawn.is_normal_exit(reason, code) then return 0 end
    return strings.count(stdout, "\n")
  end, { env = { CHECKUPDATES_DB = path.join(gfile.get_configuration_dir(), ".tmp/pacmandb") } })
  if not suc then notifs.warn("Checking pacman update count requires checkupdates from extra/pacutils") end
  return 0
end)
async({ "apt-get", "-s", "dist-upgrade" }, function(stdout, _, reason, code)
  if not spawn.is_normal_exit(reason, code) then return 0 end
  -- apt-get -s dist-upgrade | grep "^[[:digit:]]\+ upgraded"
  local upgrade_line = tables.find(strings.str2line(stdout), function(v) return v:match("^%d+ upgraded") end)
  local count = tonumber(upgrade_line:match("^(%d+) upgraded"))
  if not count or count <= 0 then return 0 end
  return count
end)
async({ "snap", "refresh", "--list" }, function(stdout, _, reason, code)
  if not spawn.is_normal_exit(reason, code) then return 0 end
  local lines = strings.count(stdout, "\n")
  if lines <= 0 then return 0 end
  return lines - 1 -- note: remove header line
end)
---Do checks for other systems (ie: pacman, zipper, etc)
