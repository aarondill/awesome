local gfile = require("gears.filesystem")
local path = require("util.path")
local strings = require("util.strings")
local default_path = table.concat({ "/usr/sbin", "/usr/bin", "/sbin", "/bin" }, path.delimiter)

---@param custom string[]|string? The path to use. Defaults to $PATH if not specified.
---@return string[] path_array
local function get_path(custom)
  local PATH = custom or os.getenv("PATH") or default_path
  if type(PATH) == "table" then return PATH end
  return strings.split(PATH, path.delimiter) -- Split the PATH by the separator
end

---Check if a program is available and pass it to the callback.
-- If a custom path is passed and a string, then it will be split by the path separator (: on unix)
---@param program string? the program to check. If nil, will not be checked.
---@param custom_path string[]|string? The path to use. Defaults to $PATH if not specified.
---@return string? The path to the program. Nil if not found.
local function which(program, custom_path)
  if not program then return nil end
  local path_arr = get_path(custom_path)
  for _, dir in ipairs(path_arr) do
    local p = ("%s/%s"):format(dir, program)
    if gfile.file_executable(p) then return p end
  end
  return nil
end

return which
