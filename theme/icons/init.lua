local gears = require("gears")
local dir = gears.filesystem.get_configuration_dir() .. "theme/icons"

return {
	logout = dir .. "/logout.svg",
	sleep = dir .. "/power-sleep.svg",
	power = dir .. "/power.svg",
	lock = dir .. "/lock.svg",
	restart = dir .. "/restart.svg",
	volume = dir .. "/volume-high.svg",
	chart = dir .. "/chart-areaspline.svg",
	memory = dir .. "/memory.svg",
	harddisk = dir .. "/harddisk.svg",
	thermometer = dir .. "/thermometer.svg",
	launcher = dir .. "/awesome.svg",
}
