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
  return "/" .. path:sub(s) -- Remove the leading (/../)+
end

---Normalizes the path without doing any file operations.
---@param path string
---@return string
local function normalize_path(path)
  ---@type string
  local res = path
    :gsub("/%./", "/") -- no /./
    :gsub("^(.+)/$", "%1") -- no end slash -- use .+ instead of .* to keep '/' instead of ''
    :gsub("//+", "/") -- no double slashes
  return remove_leading_backtrack(res)
end

return normalize_path
