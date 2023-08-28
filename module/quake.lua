local apps = require("configuration.apps")
local quake_widget = require("widget.quake")
local quake = {}

quake.class = "QuakeDD"
--- Create a quake terminal
--- This must be done before configuration.keys.global is required!
quake.instance = quake_widget({ spawn = apps.open.quake_terminal, class = quake.class })
return quake
