local apps = require("configuration.apps")
local bind = require("util.bind")
local capi = require("capi")
local quake = require("widget.quake")

local quake_class = "QuakeDD"
--- Create a quake terminal
local quakei = quake.new({ spawn = apps.open.quake_terminal, class = quake_class })
capi.awesome.connect_signal("quake::toggle", bind(quakei.toggle, quakei))
capi.awesome.connect_signal("quake::kill", bind(quakei.kill, quakei))

local M = {}
function M:client_is_quake(c) ---@param c AwesomeClientInstance
  return c.instance == quake_class
end
---This is the class used for the quake terminal. Use it only in awful.rules.
M.instance = quake_class
return M
