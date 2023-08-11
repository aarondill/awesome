local default = require("configuration.apps.default")
local open = require("configuration.apps.open")
local run_on_startup = require("configuration.apps.run_on_startup")
return {
  default = default,
  open = open,
  run_on_startup = run_on_startup,
}
