--- private function to ensure that the level is never messed up by calling other functions
--- Ensure that NONE of the functions here call each other, or level will be messed up
--- @param level integer?
--- @return string
local function getpath(level)
  level = level or 1 -- caller of M.path()
  local is_tail_call = debug.getinfo(level + 1, "t").istailcall -- info of M.{path,filename,...}()
  if is_tail_call then -- Fail quick! This is a bug and should be fixed!
    local msg = table.concat({
      "source_path module functions can not be called from a tail call! This will break your code's expectations.",
      "If this the result of TCO is what you expect, then remove the TCO and subtract one from level instead!",
      "If you are not calling a function from the source_path module, check the stack trace to find the erroneous line.",
    }, " ") -- Long, but descriptive error message. This will save me in the future :)
    error(msg, 2)
  end
  -- level + 2 because 1 == path() and 2 == M.{path,filename,...}()
  local path = debug.getinfo(level + 2, "S").source:sub(2)
  return path -- Avoid TCO! (incase this line changes/typo)
end

--- Note: All functions included in this module will return unexpected results if used with tail-call-optimization (TCO)
--- This includes `return source_path.filename()`, as well as `return function_that_uses_source_path`.
--- To fix this. Create a variable with the result and return it. `local fn = source_path.filename() return fn`
local M = {}
---Gets the file path of the file that contains the function at level 'level'
---@param level integer? pass the same number as you would to debug.getinfo(level).
---1 is the direct caller (ie, if 'a' calls filename(), 1 is 'a')
---2 is the second caller (ie, if 'a' calls 'b' and 'b' calls filename(), 2 is 'a')
---Defaults to 1: The caller of this function.
---@return string
function M.path(level)
  return getpath(level)
end
---Gets the file name of the file that contains the function at level 'level'
---Doesn't include the path or the extension of the file
---@param level integer? See path() for more information
---@return string
function M.filename(level)
  local path = getpath(level)
  return path:match("^.*/(.-).lua$") or path
end
---return name of the file
---@param level integer? See path() for more information
---@return string
function M.basename(level)
  local path = getpath(level)
  return path:match("^.*/(.-)$") or path
end
---return the directory containing the file
---Note: this does not end in a trailing slash
---@param level integer? See path() for more information
---@return string
function M.dirname(level)
  local path = getpath(level)
  return path:match("^(.*)/.-$") or path
end
---return the extension of the file (should usually be ".lua")
---if multiple extensions are present, returns only the last one
---@param level integer? See path() for more information
---@return string
function M.extension(level)
  local path = getpath(level)
  return path:match("^.*%.(.-)$") or ""
end

return M
