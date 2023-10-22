local apps = require("configuration.apps")
local bind = require("util.bind")
local capi = require("capi")
local quake_widget = require("widget.quake")

local quake_class = "QuakeDD"
--- Create a quake terminal
local quake_instance = quake_widget({ spawn = apps.open.quake_terminal, class = quake_class })
capi.awesome.connect_signal("quake::toggle", bind(quake_instance.toggle, quake_instance))

local quake = {}
function quake:client_is_quake(c) ---@param c AwesomeClientInstance
  return c.instance == quake_class
end
return quake
