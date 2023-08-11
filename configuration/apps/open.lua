local apps = require("configuration.apps")
local concat_command = require("util.concat_command")
local gears = require("gears")
local notifs = require("util.notifs")
local spawn = require("util.spawn")

---Open a terminal with the given command
---@param cmd? string|string[]
---@param spawn_options SpawnOptions? Options to pass to utils.spawn
local function open_terminal(cmd, spawn_options)
  local do_cmd = cmd and concat_command(concat_command(apps.default.terminal, { "-e" }), cmd) or apps.default.terminal
  spawn(do_cmd, spawn_options)
end

---Open a editor with the given file
---@param file? string|string[]
---@param spawn_options SpawnOptions? Options to pass to utils.spawn
local function open_editor(file, spawn_options)
  local do_cmd = file and concat_command(concat_command(apps.default.editor, { "-e" }), file) or apps.default.editor
  spawn(do_cmd, spawn_options)
end
---Open a browser with the given url
---@param url? string|string[]
---@param new_window? boolean whether to create a new window - default false
---@param spawn_options SpawnOptions? Options to pass to utils.spawn
local function open_browser(url, new_window, spawn_options)
  local new_window_arg = { "--new-window" }
  local do_cmd = apps.default.browser ---@type string|string[]
  if new_window then do_cmd = concat_command(do_cmd, new_window_arg) end
  if url then do_cmd = concat_command(do_cmd, url) end
  -- Use the user specified if present
  spawn_options = gears.table.crush({ inherit_stderr = false, inherit_stdout = false }, spawn_options or {})
  spawn(do_cmd, spawn_options)
end
---Open the lock screen
---Note, this doesn't block.
---Don't notify due to failure. This function will handle that.
---@param exit_cb? fun(success: boolean) The function to call on exit. success will be true if the screen closed normally, or false if something went wrong.
local function open_lock(exit_cb)
  local pid = spawn(apps.default.lock, {
    sn_rules = false,
    inherit_stdin = false,
    inherit_stdout = false,
    inherit_stderr = false,
    exit_callback = function(reason, code)
      if code ~= 0 then
        notifs.warn(string.format("Exit reason: %s, Exit code: %d", reason, code), {
          title = "Something went wrong running the lock screen",
        })
      end
      -- Call exit_cb with true if the screen closed normally (exit with code 0)
      if exit_cb then exit_cb(reason == "exit" and code == 0) end
    end,
  })
  if exit_cb and type(pid) == "string" then exit_cb(false) end
end

return {
  terminal = open_terminal,
  editor = open_editor,
  lock = open_lock,
  browser = open_browser,
}
