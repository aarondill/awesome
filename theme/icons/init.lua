local gfile = require("gears.filesystem")
local dir = gfile.get_configuration_dir() .. "theme/icons"

local icons = {
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
  play = dir .. "/play.svg",
  pause = dir .. "/pause.svg",
  stop = dir .. "/stop.svg",
  tag_close = dir .. "/tasklist_close.png",
  term = dir .. "/term.svg",
}
setmetatable(icons, {
  __index = function(_, key)
    local exts = {
      "svg",
      "png",
    }
    for _, ext in ipairs(exts) do
      local f = ("%s/%s.%s"):format(dir, key, ext)
      -- file exists
      if gfile.file_readable(f) then return f end
    end
    return nil
  end,
})

return icons
