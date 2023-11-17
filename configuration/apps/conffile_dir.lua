local gfile = require("gears.filesystem")
local path = require("util.path")
--- The directory containing configuration files for processes spawned
--- Note: this does NOT end in a slash.
local config_file_dir = path.resolve(gfile.get_configuration_dir(), "configuration", "conf")

return config_file_dir
