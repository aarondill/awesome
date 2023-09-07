local apps = require("configuration.apps")
local bind = require("util.bind")
local quake_widget = require("widget.quake")

local quake_class = "QuakeDD"
--- Create a quake terminal
--- This must be done before configuration.keys.global is required!
local quake_instance = quake_widget({ spawn = apps.open.quake_terminal, class = quake_class })
awesome.connect_signal("quake::toggle", bind(quake_instance.toggle, quake_instance))

local quake = {}
function quake:client_is_quake(c)
  return c.instance == quake_class
end
return quake
