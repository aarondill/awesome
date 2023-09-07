local apps = require("configuration.apps")
local quake_widget = require("widget.quake")
local quake = {}

quake.class = "QuakeDD"
--- Create a quake terminal
--- This must be done before configuration.keys.global is required!
local quake_instance = quake_widget({ spawn = apps.open.quake_terminal, class = quake.class })
awesome.connect_signal("quake::toggle", function()
  quake_instance:toggle()
end)
return quake
