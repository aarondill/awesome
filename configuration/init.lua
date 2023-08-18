local require = require("util.rel_require")
return {
  keys = require(..., "keys"), ---@module "configuration.keys"
  apps = require(..., "apps"), ---@module "configuration.apps"
  layouts = require(..., "layouts"), ---@module "configuration.layouts"
  DEBUG = false,
}
