local gio = require("lgi").Gio
---@alias GioFileMonitorMethod "monitor" | "monitor_directory" | "monitor_file"
---@alias GioFileMonitorFlags "NONE" | "WATCH_HARD_LINKS" | "SEND_MOVED" | "WATCH_MOVES" | "WATCH_MOUNTS"
---@alias GioFileMonitorEvent "CHANGED" | "CHANGES_DONE_HINT" | "DELETED" | "CREATED" | "ATTRIBUTE_CHANGED" | "PRE_UNMOUNT" | "UNMOUNTED" | "MOVED" | "RENAMED" | "MOVED_IN" | "MOVED_OUT"

---A common interface for implementing file watch functions
---@param path string the file path to watch
---@param method GioFileMonitorMethod the file watch method to call (monitor_*)
---See https://docs.gtk.org/gio/flags.FileMonitorFlags.html
---@param flags GioFileMonitorFlags[]? the flags to pass to the file watch method. nil corresponds to G_FILE_MONITOR_NONE
---@param cb fun(type: GioFileMonitorEvent, path1: string, path2: string?)
local function watch_common(path, method, flags, cb)
  if type(cb) ~= "function" then error("callback must be a function", 2) end
  if type(method) ~= "string" then error("method must be a string", 2) end
  if type(path) ~= "string" then error("path must be a string", 2) end

  local file = gio.File.new_for_path(path)
  if not file[method] then error("method " .. method .. " does not exist", 2) end

  local flag_int = gio.FileMonitorFlags["NONE"]
  if flags then
    for _, flag in ipairs(flags) do
      if gio.FileMonitorFlags[flag] then
        flag_int = flag_int & gio.FileMonitorFlags[flag] -- bitwise AND
      end
    end
  end

  file[method](file, flag_int).on_changed:connect(function(_, file1, file2, type)
    local path1 = file1:get_path() ---@type string
    ---Only if using the deprecated flag G_FILE_MONITOR_SEND_MOVED flag and event_type is G_FILE_MONITOR_EVENT_MOVED
    local path2 = file2 and file2:get_path() ---@type string?
    for k, v in pairs(gio.FileMonitorEvent) do -- Reverse lookup -- given flag value, return key
      ---@cast k GioFileMonitorEvent can't guarentee, but best I can do
      if type == v then
        return cb(k, path1, path2) ---path2 is likely nil
      end
    end
  end)
end

return watch_common
