local require = require("util.rel_require")
return {
  mod = require(..., "mod"), ---@module "configuration.keys.mod"
  global = require(..., "global"), ---@module "configuration.keys.global"
  client = require(..., "client"), ---@module "configuration.keys.client"
}
