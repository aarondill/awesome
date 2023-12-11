local require = require("util.rel_require")

local join = require(..., "join") ---@module "util.path.join"
local new_file_for_path = require("util.file.new_file_for_path")

---Returns a relative path from `from` to `to`
---Trailing slashes are stripped
---If either `from` or `to` is an empty string or nil, it's treated as the current directory
---@param from? string|GFile
---@param to? string|GFile
---@return string? path nil if no path exists. this should never happen on unix!
local function relative(from, to)
  from = from ~= "" and from or "." -- Empty strings or nil should be '.'
  to = to ~= "" and to or "." -- Empty strings or nil should be '.'
  local base = new_file_for_path(from)
  local dest = new_file_for_path(to)
  do
    if base:equal(dest) then return "." end -- Given the cwd
    local rel = base:get_relative_path(dest) -- Given a child of the cwd
    if rel then return rel end -- ./directory
  end
  -- ./../../directory
  local pathv = {} ---@type string[]
  local tmp = base ---@type GFile?
  --- Start with the cwd and progressively go ../ until dest is found under cwd.
  --- If we reach '/' and still don't have a relative path to dest, then return nil.
  --- Note: None of this does any file operations.
  while tmp and not (tmp:get_relative_path(dest) or tmp:equal(dest)) do
    tmp = tmp:get_parent()
    table.insert(pathv, "..")
  end
  -- We reached root and still didn't find it!
  -- There is no relative path between the two files (should never happen! Only on windows?)
  if not tmp then return nil end

  -- The dest is a direct parent of base
  if tmp:equal(dest) then return join(pathv) end

  local rel = assert(tmp:get_relative_path(dest), "Could not get relative path: this is a bug!")
  table.insert(pathv, rel)
  return join(pathv)
end

return relative
