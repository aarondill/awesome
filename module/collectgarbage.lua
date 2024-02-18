-- Run garbage collector regularly to prevent memory leaks
_G.collectgarbagetimer = require("gears.timer").new({
  timeout = 30,
  autostart = true,
  callback = require("util.bind").with_args(collectgarbage, "collect"),
})
