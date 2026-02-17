local basename = require("util.path.basename")
local gfilesystem = require("gears.filesystem")
local gtable = require("gears.table")
local new_file_for_path = require("util.file.new_file_for_path")
local parallel_async = require("util.parallel_async")
local Gio, GLib = require("lgi").Gio, require("lgi").GLib
local GObject = require("lgi").GObject
local a = require("a")
local exists = require("util.file.sync.exists")
local notifs = require("util.notifs")
local path = require("util.path")
local read_async = require("util.file.read_async")
local tables = require("util.tables")
local write_async = require("util.file.write_async")
---@alias URL string
---@alias WallpaperSourceSet URL[] | table<URL, string>
---@type table<string, WallpaperSourceSet>
local sets = {
  C = {
    "https://raw.githubusercontent.com/AlexandrosLiaskos/Awesome_Wallpapers/main/images/wallhaven-9mjw78.png",
    "https://raw.githubusercontent.com/AlexandrosLiaskos/Awesome_Wallpapers/main/images/staircase.jpg",
    "https://raw.githubusercontent.com/AlexandrosLiaskos/Awesome_Wallpapers/main/images/river.png",
    "https://raw.githubusercontent.com/AlexandrosLiaskos/Awesome_Wallpapers/main/images/mountains.png",
    "https://raw.githubusercontent.com/AlexandrosLiaskos/Awesome_Wallpapers/main/images/minimal_landscape.jpg",
    "https://raw.githubusercontent.com/AlexandrosLiaskos/Awesome_Wallpapers/main/images/lake.jpg",
    "https://raw.githubusercontent.com/AlexandrosLiaskos/Awesome_Wallpapers/main/images/australia.jpg",
    "https://raw.githubusercontent.com/AlexandrosLiaskos/Awesome_Wallpapers/main/images/Computerized_Art_3440x1440_7.jpg",
    "https://raw.githubusercontent.com/AlexandrosLiaskos/Awesome_Wallpapers/main/images/beach_landscape.png",
  },
  ---@type fun(done: fun(success: boolean), url: URL, dest: string)
}

---@param callback fun(success: boolean)
---@param url string
---@param dest_path string
local function download(callback, url, dest_path)
  local dest = Gio.File.new_for_path(dest_path)
  local src = Gio.File.new_for_uri(url)
  return src:copy_async(
    dest,
    "OVERWRITE",
    GLib.PRIORITY_DEFAULT,
    nil,
    nil, -- progress_callback
    GObject.Closure(function(self, task) return callback(self:copy_finish(task)) end) -- idk why this is needed
  )
end

local _tries = {
  C = 0,
}

---@param set_name string
---@param done fun(success: boolean)
---@return boolean already_downloaded if true, no done will never be called
local function get_set_async(set_name, done)
  local set = sets[set_name]
  if not set then return false end -- no urls needed in this set
  -- make `dest` relative to /wallpapers/<set>
  local p = path.resolve(gfilesystem.get_configuration_dir(), "wallpapers", set_name, "images")
  ---@type { url: URL, dest: string }[]
  local info = {}
  for k, v in pairs(set) do
    if type(v) == "string" then
      local name = basename(v)
      table.insert(info, { url = v, dest = path.resolve(p, name) })
    else
      assert(type(k) == "string")
      table.insert(info, { url = k, dest = path.resolve(p, v) })
    end
  end
  info = tables.filter(info, function(val) return not exists(val.dest) end) -- Remove existing files
  if #info == 0 then return true end
  local tries = _tries[set_name] or 0
  _tries[set_name] = tries + 1
  if tries > 3 then
    notifs.error_once("Failed to download wallpapers: too many tries", { title = "Failed to download wallpapers" })
    -- done(false)
    return false
  end
  local urls = tables.map(info, function(val) return val.url end)
  notifs.normal(tables.concat(urls, "\n"), { title = "Downloading wallpapers" })
  new_file_for_path(p):make_directory_with_parents(nil)
  parallel_async(info, function(val, cb) return download(cb, val.url, val.dest) end, function(res)
    local success = gtable.hasitem(res, false) == nil
    return done(success)
  end)
  return false
end

return {
  get_set_async = get_set_async,
}
