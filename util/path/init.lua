local M = {}

function M.join(...)
  local tbl = table.pack(...)
  return M.normalize(table.concat(tbl, "/", 1, tbl.n))
end

---Removes /../ from the string, repeatedly
---@param path string
local function remove_leading_backtrack(path)
  if path:sub(1, 1) ~= "/" then return path end -- If it isn't absolute, return it.
  local s = 1 + ("/"):len() -- Start of window
  local e = ("../"):len() + (s - 1) -- End of window
  while s < path:len() and path:sub(s, e) == "../" do -- while the window is ../ (we already know it starts with /)
    s = e + 1 -- Move forward the window (in front of previous window)
    e = e + ("../"):len() -- Move forward the window (in front of previous window)
  end
  if s > path:len() then return "/" end
  local res = "/" .. path:sub(s) -- Remove the leading (/../)+
  if res == "/.." then return "/" end -- Special case for no trailing slash
  return res
end
---Normalizes the path without doing any file operations.
---@param path string
---@return string
function M.normalize(path)
  if not path or path == "" then return path end -- empty path should be the same
  ---@type string
  local res = path
    :gsub("/%./", "/") -- no /./
    :gsub("^(.+)/$", "%1") -- no end slash -- use .+ instead of .* to keep '/' instead of ''
    :gsub("//+", "/") -- no double slashes
  if res:len() == 0 then return "." end -- We have removed everything. This shouldn't happen?
  return remove_leading_backtrack(res)
end

return M
