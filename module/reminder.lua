local notifs = require("util.notifs")
local path = require("util.path")
local read_async = require("util.file.read_async")
local spawn = require("util.spawn")
local stream = require("stream")
local strings = require("util.strings")

--- Note: the order of this matters, as the first one is the one that is used.
--- PERF: I use todo more often than reminder, so I put it first, this saves ~30 iterations.
local names = { "todo", "reminder" }
local extensions = { ".md", ".txt" }

local path_stream = stream
  .new(names)
  -- todo, .todo, .reminder, reminder
  :flatmap(function(p) return { p, "." .. p } end)
  -- todo, TODO, Todo, ...
  :flatmap(function(p) return { p:lower(), p:gsub("^%l", string.upper), p:upper() } end)
  -- todo, todo/index, ...
  :flatmap(function(p) return { p, path.join(p, "index") } end)
  --- todo, todo.txt, todo.md, todo/index.txt, todo/index.md, ...
  :flatmap(function(p) ---@param p string
    return stream.concat(stream.of(p), stream.new(extensions):map(function(e) return p .. e end))
  end)
  -- /home/user/todo, /home/user/todo/index, ...
  :map(path.get_home)

local function handler(content, _, fpath)
  if not content then -- Repeat until we find one.
    local next, done = path_stream:next() -- Try the next one.
    if done then return end -- there are no more
    return read_async(next, handler)
  end
  if #content == 0 or content:find("^%s*$") then return end -- just whitespace

  local msg = content:gsub("^\n*", ""):gsub("\n*$", ""):gsub("\n\n\n", "\n\n")
  return notifs.normal(msg, { title = ("Reminder (%s)"):format(path.tildify(fpath)) })
end
read_async(path_stream:next(), handler)

--- Spawn the `todo` command to get the todo list
spawn.async_success({ "todo", "count" }, function(stdout_count)
  stdout_count = tonumber(stdout_count)
  if not stdout_count or stdout_count == 0 then return end
  return spawn.async_success({ "todo", "list" }, function(stdout)
    local out = strings.trim(stdout)
    if out == "" then return end
    local todo_s = strings.pluralize("todo", stdout_count)
    return notifs.info(out, { title = ("You have %d %s"):format(stdout_count, todo_s) })
  end)
end)
