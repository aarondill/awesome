local require = require("util.rel_require")
--
local append_async = require("util.file.append_async")
local ascreen = require("awful.screen")
local await = require("await")
local concat_command = require("util.command.concat_command")
local default = require(..., "default") ---@module 'configuration.apps.default'
local lgi = require("lgi")
local new_file_for_path = require("util.file.new_file_for_path")
local notifs = require("util.notifs")
local path = require("util.path")
local rofi_command = require(..., "rofi_command") ---@module 'configuration.apps.rofi_command'
local spawn = require("util.spawn")
local widgets = require("util.awesome.widgets")
local xdg_user_dir = require("util.command.xdg_user_dir")
local GLib, Gio = lgi.GLib, lgi.Gio

local open = {}

---@param dir string
---@param ... string
local function get_xdg_dir(dir, ...) ---@return string
  local dest = path.join(assert(xdg_user_dir(dir), "Invalid XDG directory: " .. dir), ...)
  assert(require("gears.filesystem").make_directories(dest)) -- Ensure parent directory exists
  return dest
end
---@param cmd string|string[]
local function cmd_tostring(cmd) return type(cmd) == "string" and cmd or require("util.command.shell_escape")(cmd) end

---@param cmd string|string[]
---@param err string?
local function notif_error(cmd, err)
  -- Warn the user!
  local msg = table.concat({
    ("Error: %s"):format(err),
    ("Command: %s"):format(cmd_tostring(cmd)),
  }, "\n")
  notifs.critical(msg, { title = "Failed to execute program!" })
end
---@param cmd string|string[]
---@param opts SpawnOptions? Options to pass to utils.spawn
---Warns the user if a command fails to spawn. Returns the same values as spawn.spawn
local function spawn_notif_on_err(cmd, opts)
  local info, err = spawn.spawn(cmd, opts)
  if not info then notif_error(cmd, err) end
  return info, err
end

---Open a terminal with the given command
---@param cmd? string|string[]
---@param spawn_options SpawnOptions? Options to pass to utils.spawn
function open.terminal(cmd, spawn_options)
  local do_cmd = default.terminal ---@type string|string[]
  if cmd then
    do_cmd = concat_command(do_cmd, { "-e" })
    do_cmd = concat_command(do_cmd, cmd)
  end
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
  local do_cmd = default.editor ---@type string|string[]
  if file then
    do_cmd = concat_command(do_cmd, { "--" })
    do_cmd = concat_command(do_cmd, file)
  end
  return spawn_notif_on_err(do_cmd, spawn_options)
end

---Open a browser with the given url
---@param url? string|string[]
---@param new_window? boolean whether to create a new window - default false
---@param incognito? boolean whether to open incognito - default false
---@param spawn_options SpawnOptions? Options to pass to utils.spawn
function open.browser(url, new_window, incognito, spawn_options)
  local do_cmd = default.browser.open ---@type string|string[]
  if new_window then do_cmd = concat_command(do_cmd, default.browser.new_window) end
  if incognito then do_cmd = concat_command(do_cmd, default.browser.incognito) end
  if url then
    do_cmd = concat_command(do_cmd, { "--" })
    do_cmd = concat_command(do_cmd, url)
  end
  -- Use the user specified if present
  spawn_options = spawn_options or {}
  spawn_options.inherit_stderr = false
  spawn_options.inherit_stdout = false
  local info = spawn_notif_on_err(do_cmd, spawn_options)
  if not info then return end

  --- Close stdout and stderr
  --- In this specific case, this is fine because chromium-based browsers open cat processes for their stdio
  --- These processes can die without the browser being killed by sigpipe.
  --- See https://github.com/awesomeWM/awesome/issues/3865 for the (eventual) better way to do this.
  return require("stream").of(info.stderr_fd, info.stdout_fd):foreach(GLib.close)
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
      local promptbox = s and s.top_panel and widgets.get_by_id(s.top_panel, "run_prompt")
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

---Open a terminal with the given command
---@param window? AwesomeClientInstance|{x: integer, y: integer, width: integer, height: integer}
---@param callback? fun(path?: string): any? Called with the filepath of the new screenshot if successful
---@param spawn_options? SpawnOptions Options to pass to utils.spawn
function open.screenshot(window, callback, spawn_options)
  callback = callback or function() end
  local cmd = concat_command(default.region_screenshot, { "-p", get_xdg_dir("PICTURES", "Screenshots") })
  if window then
    local x, y, width, height = window.x, window.y, window.width, window.height
    cmd = concat_command(cmd, { "--region", ("%sx%s+%s+%s"):format(width, height, x, y) })
    if window.raise then window:raise() end -- ensure the selected client is visible
  end

  spawn_options = spawn_options or {}
  spawn_options.on_failure_callback = function(err) return notif_error(cmd, err) end
  return spawn.async(cmd, function(_, stderr, reason, code)
    if not spawn.is_normal_exit(reason, code) then return callback(nil) end
    return callback(stderr:match("Capture saved as ([^\n]*)"))
  end, spawn_options)
end

return open
