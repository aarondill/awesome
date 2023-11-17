local gfile = require("gears.filesystem")
local path = require("util.path")
local dir = path.join(gfile.get_configuration_dir(), "theme", "icons")

local icons = {
  --- Note: this doesn't end in a slash!
  DIR = dir,

  logout = path.join(dir, "logout.svg"),
  sleep = path.join(dir, "power-sleep.svg"),
  power = path.join(dir, "power.svg"),
  lock = path.join(dir, "lock.svg"),
  restart = path.join(dir, "restart.svg"),
  volume = path.join(dir, "volume-high.svg"),
  chart = path.join(dir, "chart-areaspline.svg"),
  memory = path.join(dir, "memory.svg"),
  harddisk = path.join(dir, "harddisk.svg"),
  thermometer = path.join(dir, "thermometer.svg"),
  launcher = path.join(dir, "awesome.svg"),
  play = path.join(dir, "play.svg"),
  pause = path.join(dir, "pause.svg"),
  stop = path.join(dir, "stop.svg"),
  tag_close = path.join(dir, "tasklist_close.png"),
  term = path.join(dir, "term.svg"),
  layout = {
    tile = path.join(dir, "layouts", "tile-right.svg"),
    tileleft = path.join(dir, "layouts", "tile-left.svg"),
    spiral = path.join(dir, "layouts", "spiral.svg"),
    dwindle = path.join(dir, "layouts", "dwindle.svg"),
    tilebottom = path.join(dir, "layouts", "tile-bottom.svg"),
    tiletop = path.join(dir, "layouts", "tile-top.svg"),
    fairh = path.join(dir, "layouts", "fair-horizontal.svg"),
    fairv = path.join(dir, "layouts", "fair.svg"),
    floating = path.join(dir, "layouts", "floating.svg"),
    magnifier = path.join(dir, "layouts", "magnifier.svg"),
    cornerne = path.join(dir, "layouts", "cornerne.svg"),
    cornernw = path.join(dir, "layouts", "cornernw.svg"),
    cornersw = path.join(dir, "layouts", "cornersw.svg"),
    cornerse = path.join(dir, "layouts", "cornerse.svg"),
    fullscreen = path.join(dir, "layouts", "fullscreen.svg"),
    max = path.join(dir, "layouts", "max.svg"),
  },
  titlebar = {
    go_up = path.join(dir, "titlebar", "go-up.svg"),
    go_down = path.join(dir, "titlebar", "go-down.svg"),
    window_close = path.join(dir, "titlebar", "window-close.svg"),
  },
}
setmetatable(icons, {
  __index = function(_, key)
    local exts = {
      "svg",
      "png",
    }
    for _, ext in ipairs(exts) do
      local f = path.join(dir, table.concat({ key, ext }, "."))
      -- file exists
      if gfile.file_readable(f) then return f end
    end
    return nil
  end,
})

return icons
