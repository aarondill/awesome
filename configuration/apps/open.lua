local require = require("util.rel_require")

local concat_command = require("util.concat_command")
local default = require(..., "default") ---@module 'configuration.apps.default'
local notifs = require("util.notifs")
local spawn = require("util.spawn")
local tableutils = require("util.table")

local open = {}

---@param cmd string|string[]
---@param opts SpawnOptions? Options to pass to utils.spawn
---@param noninteractive boolean? if true: call spawn.noninteractive
---Warns the user if a command fails to spawn. Returns the same values as spawn.spawn
local function spawn_notif_on_err(cmd, opts, noninteractive)
  opts = opts or {}
  opts.on_failure_callback = function(err)
    local cmd_string = type(cmd) == "table" and tableutils.concat(cmd, "'%s'", " ") or tostring(cmd)
    return notifs.critical( -- Warn the user!
      ("Error: %s\nCommand: %s"):format(err, cmd_string),
      { title = "Failed to execute program!" }
    )
  end
  local f = noninteractive and spawn.noninteractive or spawn.spawn
  return f(cmd, opts)
end

---Open a terminal with the given command
---@param cmd? string|string[]
---@param spawn_options SpawnOptions? Options to pass to utils.spawn
function open.terminal(cmd, spawn_options)
  local do_cmd = cmd and concat_command(concat_command(default.terminal, { "-e" }), cmd) or default.terminal
  return spawn_notif_on_err(do_cmd, spawn_options)
end
---Open a quake terminal
---@param class string
function open.quake_terminal(class)
  --HACK: This only works with wezterm!
  local do_cmd = concat_command(default.terminal, { "start", "--class", class })
  return spawn_notif_on_err(do_cmd)
end

---Open a editor with the given file
---@param file? string|string[]
---@param spawn_options SpawnOptions? Options to pass to utils.spawn
function open.editor(file, spawn_options)
  local do_cmd = file and concat_command(concat_command(default.editor, { "-e" }), file) or default.editor
  return spawn_notif_on_err(do_cmd, spawn_options)
end
---Open a browser with the given url
---@param url? string|string[]
---@param new_window? boolean whether to create a new window - default false
---@param spawn_options SpawnOptions? Options to pass to utils.spawn
function open.browser(url, new_window, spawn_options)
  local new_window_arg = { "--new-window" }
  local do_cmd = default.browser ---@type string|string[]
  if new_window then do_cmd = concat_command(do_cmd, new_window_arg) end
  if url then do_cmd = concat_command(do_cmd, url) end
  -- Use the user specified if present
  return spawn_notif_on_err(do_cmd, spawn_options, true)
end
---Open the lock screen
---Note, this doesn't block.
function open.lock()
  ---@param reason_or_err 'exit'|'signal'|string
  ---@param code integer?
  local function warn(reason_or_err, code)
    local format = code and "Exit reason: %s, Exit code: %d" or "Error: %s"
    local msg = format:format(reason_or_err, code)
    return notifs.warn(msg, { title = "Something went wrong running the lock screen" })
  end
  return spawn.noninteractive_nosn(default.lock, { exit_callback_err = warn, on_failure_callback = warn })
end

return open
