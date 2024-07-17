local path = require("util.path")
local source_path = require("util.source_path")

local version = _VERSION:match("%d+%.%d+")
if not version then
  require("util.notifs").error("Could not determine lua version!")
  return { path = {}, cpath = {} }
end

local deps = source_path.dirname()
local dirs = {
  path.join(deps, ".lua"),
}

local build_dir = path.resolve(deps, ".build") -- This file -> ./.build
-- These are directories that should be added to pacakge.[c]path to make dependencies requireable
return {
  path = { ---@type string[]
    path.join(build_dir, "share", "lua", version),
    table.unpack(dirs),
  },
  cpath = { ---@type string[]
    path.join(build_dir, "lib", "lua", version),
    table.unpack(dirs),
  },
}
