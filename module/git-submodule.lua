local Gio = require("lgi").Gio
local gfile = require("gears.filesystem")
local notifs = require("util.notifs")

-- I *need* this to be synchronous so the modules are available later in the code.
-- So, this is a rare exception. This command should only take a long time the first time it is called.

-- -C=run in this directory, since lua doesn't support 'cd'ing
local cmd = { "git", "-C", gfile.get_configuration_dir(), "submodule", "update", "--init", "--recursive" }

local flags = { "STDOUT_PIPE", "STDERR_SILENCE" } ---@type GSubprocessFlags[]
local process = Gio.Subprocess.new(cmd, flags)
if not process then return end
local stdout = assert(process:get_stdout_pipe())
local input = Gio.DataInputStream.new(stdout)
local fline = input:read_line()
if fline then
  notifs.info("Updating git submodules")
  notifs.info(tostring(fline))
end
-- Give a progress notification on each line
while true do
  local line = input:read_line()
  if not line then break end
  notifs.info(tostring(line))
end
