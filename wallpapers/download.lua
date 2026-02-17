local basename = require("util.path.basename")
local exists = require("util.file.sync.exists")
local gfilesystem = require("gears.filesystem")
local gtable = require("gears.table")
local lgi = require("lgi")
local new_file_for_path = require("util.file.new_file_for_path")
local notifs = require("util.notifs")
local parallel_async = require("util.parallel_async")
local path = require("util.path")
local tables = require("util.tables")
local Gio, GLib, GObject = lgi.Gio, lgi.GLib, lgi.GObject
---@class URL :string
---@alias WallpaperSourceSet URL[] | table<URL, string>

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
  ---@type boolean, WallpaperSourceSet
  local ok, set = pcall(require, "wallpapers." .. set_name .. ".sources")
  if not ok or not set then return false end -- no urls needed in this set
  assert(type(set) == "table")
  -- make `dest` relative to /wallpapers/<set>
  local p = path.resolve(gfilesystem.get_configuration_dir(), "wallpapers", set_name, "images")
  ---@type { url: URL, dest: string }[]
  local info = {}
  for k, v in pairs(set) do
    local r
    if type(v) == "string" then
      local name = basename(v)
      r = { url = v, dest = path.resolve(p, name) }
    else
      assert(type(k) == "string")
      r = { url = k, dest = path.resolve(p, v) }
    end
    if not exists(r.dest) then table.insert(info, r) end -- Remove existing files
  end
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
