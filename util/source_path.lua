--- private function to ensure that the level is never messed up by calling other functions
--- Ensure that NONE of the functions here call each other, or level will be messed up
--- @param level integer?
--- @return string
local function getpath(level)
  level = level or 1 -- caller of M.path()
  -- level + 2 because 1 == path() and 2 == M.{path,filename,...}()
  return debug.getinfo(level + 2, "S").source:sub(2)
end

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
