local require = require("util.rel_require")
return {
  apps = require(..., "apps"), ---@module "configuration.apps"
  keys = require(..., "keys"), ---@module "configuration.keys"
  layouts = require(..., "layouts"), ---@module "configuration.layouts"
  DEBUG = false,
}
