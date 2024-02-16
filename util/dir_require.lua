local exists = require("util.file.sync.exists")
local find_module = require("util.find_module")
local ls = require("util.file.sync.ls")
local path = require("util.path")

---@param modname string
---@return string?
local function find_root(modname)
  local ret = find_module.find(modname, {
    patterns = { "", ".lua" },
  })[1]
  if not ret then return end
  -- /module/child/init.lua -> /module/child AND /module/child.lua -> /module/child
  return (ret.modpath:gsub("/init%.lua$", ""):gsub("%.lua$", ""))
end

---Requires all files in a directory
---Filepath must be a path in which slashes can be replaced with dots to make it a lua module
---@param modname string
---@return true?, (GError|string)?
local function dir_require(modname)
  local root = find_root(modname)
  if not root then return nil, "Could not find " .. modname end
  local res = {} ---@type ({ mod: string, path: string })[]

  local suc, err = ls(root, function(pathname, name, type)
    if name == "init.lua" then -- /module/child/init.lua
      res[#res + 1] = { mod = modname, path = pathname }
    elseif type == "REGULAR" and path.extname(name) == ".lua" then -- /module/child/*.lua
      res[#res + 1] = { mod = modname .. "." .. path.basename(name, ".lua"), path = pathname }
    elseif type == "DIRECTORY" and exists(path.join(pathname, "init.lua")) then -- /module/child/*/init.lua
      res[#res + 1] = { mod = modname .. "." .. name, path = path.join(pathname, "init.lua") }
    end
  end)
  if not suc then return nil, err end

  table.sort(res, function(a, b)
    return a.path < b.path
  end) -- sort alphabetically
  local log = {}
  for _, m in ipairs(res) do
    table.insert(log, m.mod)
    require(m.mod)
  end
end

return dir_require
