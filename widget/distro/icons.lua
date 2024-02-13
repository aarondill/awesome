local bind = require("util.bind")
local file_type_async = require("util.file.file_type_async")
local path = require("util.path")
local source_path = require("util.source_path")
local spawn = require("util.spawn")
local M = {}
--- Regenerate the zip file with this command: zip -m9rTy icons.zip icons/
--- Unzips the icons.zip file and calls cb when done
---@param cb fun(dir: string)
function M.unzip_icons(cb)
  local scriptdir = source_path.dirname()
  local icondir = path.join(scriptdir, "icons")
  return file_type_async(icondir, function(type)
    if type == "DIRECTORY" then return cb(icondir) end -- already exists
    local zipfile = path.join(scriptdir, "icons.zip")
    -- If unzip is not available, this will silently fail. That's ok. We just don't set the icon.
    return spawn.spawn({ "unzip", zipfile, "-d", scriptdir }, { exit_callback_suc = bind.with_args(cb, icondir) })
  end)
end
return M
