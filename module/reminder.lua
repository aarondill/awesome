local find_home = require("util.find_home")
local gtable = require("gears.table")
local notifs = require("util.notifs")
local read_async = require("util.file.read_async")

---Return a table of permutations of extensions
---Note: this boils down to ("%s.%s"):format. It does *no* path manipulation.
---Ensure the path is properly formatted and doesn't end in a `.`
---if you don't expect multiple dots. Ditto for the extension array
---@param path string|string[]
---@param exts string[]
---@param include_original boolean? Should `path` be included in the result? Default: true
---@return string[]
local function extensions(path, exts, include_original)
  include_original = include_original == nil and true or include_original -- default to true
  if type(path) == "table" then
    local ret = include_original and gtable.clone(path, false) or {}
    for _, p in ipairs(path) do
      gtable.merge(ret, extensions(p, exts, false)) -- Don't include original to remove duplicates
    end
    return ret
  end

  local ret = include_original and { path } or {}
  for _, ext in ipairs(exts) do
    table.insert(ret, ("%s.%s"):format(path, ext))
  end
  return ret
end
local home_reminder_paths = { "reminder", ".reminder", ".todo", "todo" }
local paths = extensions(gtable.map(find_home, home_reminder_paths), { "txt", "md" })
local index = 1

local function handler(content, _, path)
  if not content then -- Repeat until we find one.
    index = index + 1 -- Try the next one.
    if not paths[index] then return end
    return read_async(paths[index], handler)
  end
  if #content == 0 or content:find("^%s*$") then return end -- just whitespace

  local msg = content:gsub("^\n*", ""):gsub("\n*$", ""):gsub("\n\n\n", "\n\n")
  return notifs.info(msg, { title = ("Reminder (%s)"):format(path) })
end

return read_async(paths[index], handler)
