local gfile = require("gears.filesystem")
local dir = gfile.get_configuration_dir() .. "theme/icons"

local icons = {
  --- Note: this doesn't end in a slash!
  DIR = dir,

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
  layout = {
    tile = dir .. "/layouts/tile-right.svg",
    tileleft = dir .. "/layouts/tile-left.svg",
    spiral = dir .. "/layouts/spiral.svg",
    dwindle = dir .. "/layouts/dwindle.svg",
    tilebottom = dir .. "/layouts/tile-bottom.svg",
    tiletop = dir .. "/layouts/tile-top.svg",
    fairh = dir .. "/layouts/fair-horizontal.svg",
    fairv = dir .. "/layouts/fair.svg",
    floating = dir .. "/layouts/floating.svg",
    magnifier = dir .. "/layouts/magnifier.svg",
    cornerne = dir .. "/layouts/cornerne.svg",
    cornernw = dir .. "/layouts/cornernw.svg",
    cornersw = dir .. "/layouts/cornersw.svg",
    cornerse = dir .. "/layouts/cornerse.svg",
    fullscreen = dir .. "/layouts/fullscreen.svg",
    max = dir .. "/layouts/max.svg",
  },
  titlebar = {
    go_up = dir .. "/titlebar/go-up.svg",
    go_down = dir .. "/titlebar/go-down.svg",
    window_close = dir .. "/titlebar/window-close.svg",
  },
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
