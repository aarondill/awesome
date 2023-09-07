local gfile = require("gears.filesystem")
--- The directory containing configuration files for processes spawned
--- Note: this does NOT end in a slash.
local config_file_dir = gfile.get_configuration_dir() .. "configuration/conf"

return config_file_dir
