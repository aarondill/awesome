local gfile = require("gears.filesystem")
local strings = require("util.strings")

---Check if a program is available and pass it to the callback.
---@param program string? the program to check. If nil, will not be checked.
---@param path string? The path to use. Defaults to $PATH if not specified.
---@return string? The path to the program. Nil if not found.
local function which(program, path)
  if not program then return nil end
  ---@type string
  local PATH = path or os.getenv("PATH") or "/usr/sbin:/usr/bin:/sbin:/bin"
  for _, dir in ipairs(strings.split(PATH, ":")) do
    local p = ("%s/%s"):format(dir, program)
    if gfile.file_executable(p) then return p end
  end
  return nil
end

return which
