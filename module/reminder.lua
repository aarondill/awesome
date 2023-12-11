local gtable = require("gears.table")
local notifs = require("util.notifs")
local path = require("util.path")
local read_async = require("util.file.read_async")
local tables = require("util.tables")

---Return a table of permutations of extensions
---Note: this boils down to ("%s%s"):format. It does *no* path manipulation.
---@param filepath string|string[]
---@param exts string[]
---@param include_original boolean? Should `path` be included in the result? Default: true
---@return string[]
local function add_suffix(filepath, exts, include_original)
  include_original = include_original == nil and true or include_original -- default to true
  if type(filepath) == "table" then
    local ret = include_original and gtable.clone(filepath, false) or {}
    for _, p in ipairs(filepath) do
      gtable.merge(ret, add_suffix(p, exts, false)) -- Don't include original to remove duplicates
    end
    return ret
  end

  local ret = include_original and { filepath } or {}
  for _, ext in ipairs(exts) do
    table.insert(ret, ("%s%s"):format(filepath, ext))
  end
  return ret
end
local home_reminder_paths = { "reminder", ".reminder", ".todo", "todo" }
local extensions = { ".txt", ".md" }
--- These should be /todo, /todo.txt, /todo.md, ...
local files_wo_extensions = add_suffix(path.sep, home_reminder_paths, false)
local allowed_files = add_suffix(files_wo_extensions, extensions, true)
--- reminder/todo.txt, todo.txt, .reminder.md, ...
local paths = add_suffix(tables.map_val(home_reminder_paths, path.get_home), gtable.join(extensions, allowed_files))
local index = 1

local function handler(content, _, fpath)
  if not content then -- Repeat until we find one.
    index = index + 1 -- Try the next one.
    if not paths[index] then return end
    return read_async(paths[index], handler)
  end
  if #content == 0 or content:find("^%s*$") then return end -- just whitespace

  local msg = content:gsub("^\n*", ""):gsub("\n*$", ""):gsub("\n\n\n", "\n\n")
  return notifs.info(msg, { title = ("Reminder (%s)"):format(path.tildify(fpath)) })
end
return read_async(paths[index], handler)
