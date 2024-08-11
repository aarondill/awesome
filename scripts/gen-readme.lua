#!/usr/bin/env lua
local lgi = require("lgi")
local GLib, Gio = lgi.GLib, lgi.Gio
local packages = require("setup").packages
local utils = require("utils")

local script_dir = debug.getinfo(1).source:match("@?(.*/)") or "."
---NOTE: Assumes this script is located in ./scripts/
local dir = assert(Gio.File.new_for_path(script_dir):get_parent(), "Failed to get root directory")
assert(dir:query_exists(), "Current directory does not exist")
assert(GLib.chdir(assert(dir:get_path())) == 0, "Failed to change directory")

local readme_template = Gio.File.new_for_path("./README.tmpl.md")
local readme = Gio.File.new_for_path("./README.md")

---@param distro string
---@param pkgs table<string, string>
---@return string markdown header(distro) + table of packages
local function _gen_pkgs(distro, pkgs)
  local pkgs_str = table.concat(pkgs, "\n") .. "\n"
  return ([[
## %s
%s
]]):format(distro, pkgs_str)
end

---@param data table<string, string>
local function _template(data)
  local template = assert(readme_template:load_contents(nil))
  assert(template, "BUG: unreachable")
  local lines = {}
  for line in template:gmatch("[^\n]+") do
    line = line:gsub("^%s*{{([%w_])}}%s*$", data)
    lines[#lines + 1] = line
  end
  local contents = table.concat(lines, "\n")
  assert(readme:replace_contents(contents, nil, false, Gio.FileCreateFlags.REPLACE_DESTINATION, nil))
end

local data = {
  ---@type string
  ["program-list"] = "",
}
for id, list in pairs(packages) do
  ---@type PackageList
  local p
  if list._repo then
    p = utils.table_merge(list._repo, list._extra)
  else
    assert(not list._extra, "BUG: extra packages without repo packages")
    p = list --[[@as PackageList]]
  end
  data["program-list"] = data["program-list"] .. _gen_pkgs(id, p)
end
_template(data)
