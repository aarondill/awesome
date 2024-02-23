--- Based on vim.loader and lazy.nvim/lua/lazy/core/cache.lua
--- It had to be heavily modified to run outside of vim

local exists = require("util.file.sync.exists")
local gtable = require("gears.table")
local ls = require("util.file.sync.ls")
local path = require("util.path")
local strings = require("util.strings")
local M = {}

local Loader = {
  _indexed = {}, ---@type table<string, table<string,ModuleInfo>>
  _topmods = {}, ---@type table<string, string[]>
}

--- Return the top-level `$path/*` modules
---@param filepath string path to check for top-level lua modules
function Loader.lsmod(filepath)
  if Loader._indexed[filepath] then return Loader._indexed[filepath] end
  Loader._indexed[filepath] = {}
  ls(filepath, function(modpath, name, type)
    local topname ---@type string?
    local ext = path.extname(name)
    if ext == ".lua" or ext == ".dll" or ext == ".so" then
      topname = path.basename(name, ext)
    elseif type == "DIRECTORY" then
      topname = name
    end
    if topname then
      Loader._indexed[filepath][topname] = { modpath = modpath, modname = topname }
      Loader._topmods[topname] = Loader._topmods[topname] or {}
      if not gtable.hasitem(Loader._topmods[topname], filepath) then
        table.insert(Loader._topmods[topname], filepath)
      end
    end
  end)
  return Loader._indexed[filepath]
end

---@class ModuleInfo
---@field modpath string Path of the module
---@field modname string Name of the module

---@class ModuleFindOpt
---@field package_path? boolean Search for modname in the package.path (defaults to `true`)
---A pattern is a string added to the basename of the Lua module being searched.
---@field patterns? string[] Patterns to use (defaults to `{"/init.lua", ".lua"}`)
---@field paths? string[] Extra paths to search for modname (defaults to `{}`)
---@field all? boolean Return all matches instead of just the first one (defaults to `false`)

--- Finds lua modules for the given module name.
---@param modname string Module name
---@param opts? ModuleFindOpt (table|nil) Options for finding a module:
---@return ModuleInfo[] (list) A list of results
function M.find(modname, opts)
  opts = opts or {}
  modname = modname:gsub("/", ".")
  local idx = modname:find(".", 1, true)
  if idx == 1 then -- fix broken require paths
    modname = modname:gsub("^%.+", "")
    idx = modname:find(".", 1, true)
  end
  local basename = modname:gsub("%.", "/")

  -- get the top-level module name
  local topmod = idx and modname:sub(1, idx - 1) or modname

  -- OPTIM: search for a directory first when topmod == modname
  local patterns = opts.patterns or (topmod == modname and { "/init.lua", ".lua" } or { ".lua", "/init.lua" })
  for p, pattern in ipairs(patterns) do
    patterns[p] = table.concat({ "/", basename, pattern })
  end

  ---@type ModuleInfo[]
  local results = {}
  local function continue() return #results == 0 or opts.all end

  -- Checks if the given paths contain the top-level module.
  -- If so, it tries to find the module path for the given module name.
  local function _find(paths) ---@param paths string[]
    for _, p in ipairs(paths) do
      if Loader.lsmod(p)[topmod] then
        for _, pattern in ipairs(patterns) do
          local modpath = p .. pattern
          if exists(modpath) then
            results[#results + 1] = { modpath = path.normalize(modpath), modname = modname }
            if not continue() then return end
          end
        end
      end
    end
  end

  -- always check the package.path first
  if opts.package_path ~= false then
    local package_path_set = {}
    -- /dir/?.lua -> /dir AND /dir/?/init.lua -> /dir
    for _, v in ipairs(strings.split(package.path, ";")) do
      local dir = v:gsub("/%?%.lua", ""):gsub("%?/init%.lua", "")
      if not dir:find("?", 1, true) then -- ignore paths we can't handle properly
        package_path_set[dir] = dir -- dedupe
      end
    end
    local package_path = {}
    for v in pairs(package_path_set) do
      package_path[#package_path + 1] = v
    end
    _find(package_path)
  end

  -- check any additional paths
  if continue() and opts.paths then _find(opts.paths) end
  return results
end
return M
