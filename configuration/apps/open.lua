local require = require("util.rel_require")

local ascreen = require("awful.screen")
local concat_command = require("util.concat_command")
local default = require(..., "default") ---@module 'configuration.apps.default'
local get_child_by_id = require("util.get_child_by_id")
local lgi = require("lgi")
local notifs = require("util.notifs")
local rofi_command = require(..., "rofi_command") ---@module 'configuration.apps.rofi_command'
local spawn = require("util.spawn")
local tableutils = require("util.tables")
local Gio = lgi.Gio

local open = {}

---@param cmd string|string[]
---@param opts SpawnOptions? Options to pass to utils.spawn
---Warns the user if a command fails to spawn. Returns the same values as spawn.spawn
local function spawn_notif_on_err(cmd, opts)
  opts = opts or {}
  opts.on_failure_callback = function(err)
    local cmd_string = type(cmd) == "table" and tableutils.concat(cmd, "'%s'", " ") or tostring(cmd)
    return notifs.critical( -- Warn the user!
      ("Error: %s\nCommand: %s"):format(err, cmd_string),
      { title = "Failed to execute program!" }
    )
  end
  return spawn.spawn(cmd, opts)
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
  spawn_options = spawn_options or {}
  spawn_options.inherit_stderr = false
  spawn_options.inherit_stdout = false
  local info = spawn_notif_on_err(do_cmd, spawn_options)
  if not info then return end
  for _, fd in ipairs({ info.stderr_fd, info.stdout_fd }) do
    --- Close stdout and stderr
    --- In this specific case, this is fine because chromium-based browsers open cat processes for their stdio
    --- These processes can die without the browser being killed by sigpipe.
    --- See https://github.com/awesomeWM/awesome/issues/3865 for the (eventual) better way to do this.
    Gio.UnixInputStream.new(fd, true):close()
  end
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
  return spawn.nosn(default.lock, { exit_callback_err = warn, on_failure_callback = warn })
end

---Opens rofi
---@param mode string?
---TODO: mode should be an enum
function open.rofi(mode)
  mode = type(mode) == "string" and mode or nil -- Non-strings should be silently ignored
  local function rofi_failure_callback()
    --- no mode, or drun or run use promptbox, otherwise warn!
    if not mode or mode == "drun" and mode == "run" then
      local s = ascreen.focused() ---@type AwesomeScreenInstance?
      local promptbox = s and s.top_panel and get_child_by_id(s.top_panel, "run_prompt")
      if not promptbox then return end
      promptbox:run()
    elseif mode == "window" then
      require("awful.menu").clients({ theme = { width = 250 } }, { keygrabber = true, coords = { x = 525, y = 330 } })
    else
      notifs.critical(("Rofi is required to open the %s picker."):format(mode))
    end
  end
  return spawn.spawn(rofi_command(mode), {
    sn_rules = false, -- rofi supports it, but if it fails, we don't want to wait for it.
    exit_callback_err = function(reason, code)
      if reason == "exit" and code == 127 then rofi_failure_callback() end
    end,
    on_failure_callback = rofi_failure_callback,
  })
end

return open
