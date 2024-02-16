local gfile = require("gears.filesystem")
local notifs = require("util.notifs")
local shell_escape = require("util.command.shell_escape")

-- NEVER use io.popen. But, I *need* this to be synchronous so the modules are available later in the code.
-- So, this is a rare exception. This command should only take a long time the first time it is called.
if not io.popen then return end

-- -C=run in this directory, since lua doesn't support 'cd'ing
local cmd = shell_escape({ "git", "-C", gfile.get_configuration_dir(), "submodule", "update", "--init", "--recursive" })

local file = io.popen(cmd, "r")
if not file then return end
local fline = file:read("l") -- Consumes the first line
if fline then
  notifs.info("Updating git submodules")
  notifs.info(tostring(fline))
end
-- Give a progress notification on each line
for line in file:lines("l") do
  notifs.info(tostring(line))
end
file:close()
