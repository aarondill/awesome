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
  opts.on_failure_callback = function(err, command)
    local cmd_string = type(command) == "table" and tableutils.concat(command, "'%s'", " ") or command
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
---Don't notify due to failure. This function will handle that.
---@param exit_cb? fun(success: boolean) The function to call on exit. success will be true if the screen closed normally, or false if something went wrong.
function open.lock(exit_cb)
  return spawn.noninteractive(default.lock, {
    sn_rules = false,
    exit_callback = function(reason, code)
      local is_normal_exit = spawn.is_normal_exit(reason, code)
      if not is_normal_exit then
        notifs.warn(("Exit reason: %s, Exit code: %d"):format(reason, code), {
          title = "Something went wrong running the lock screen",
        })
      end
      -- Call exit_cb with true if the screen closed normally (exit with code 0)
      if exit_cb then return exit_cb(is_normal_exit) end
    end,
    on_failure_callback = function()
      if exit_cb then return exit_cb(false) end
    end,
  })
end

return open
