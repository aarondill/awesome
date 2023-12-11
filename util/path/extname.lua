local require = require("util.rel_require")

local basename = require(..., "basename") ---@module 'util.path.basename'
--- The path.extname() method returns the extension of the path, from the last
--- dot to end of string in the last portion of the path.
--- If the path has no extension or begins with a dot (and no other dot), and empty string is returned
---@param path string
---@return string
local function extname(path)
  return basename(path):match(".+(%..+)") or ""
end
return extname
