local gtable = require("gears.table")
local gtimer = require("gears.timer")
local notifs = require("util.notifs")
local spawn = require("util.spawn")
local strings = require("util.strings")

local M = { notification_count = 0, default_debounce_duration = 60 }
local state = { last_refresh = nil, debounce_duration = M.default_debounce_duration }

-- Returns a string formatted for the Last-Modified header
---@param seconds_since_epoch integer?
local function generate_last_modified(seconds_since_epoch)
  seconds_since_epoch = seconds_since_epoch or os.time()
  local ret = os.date("!%a, %d %b %Y %H:%M:%S GMT", seconds_since_epoch) -- Here, ! enforces GMT
  assert(type(ret) == "string")
  return ret
end

--- Output on changed (code=0): (gh api notifications -i -t '{{ len . }}')
--- HTTP/2.0 200 OK
--- ...
--- X-Poll-Interval: 60
--- ...
--- <EMPTY LINE>
--- 0

--- Output when not changed! (code=1)
--- HTTP/2.0 304 Not Modified
--- ...
--- X-Poll-Interval: 60
--- ...
--- <EMPTY LINE>
--- <EMPTY LINE>

--- Output on error (code=1):
--- HTTP/2.0 422 Unprocessable Entity
--- ...
--- <EMPTY LINE>
--- {"message":"...","documentation_url":"..."}

---@class CurlReturn
---@field http_version string
---@field status integer
---@field status_text string
---@field ok boolean whether the response was successful (status in the range 200-299) or not.
---@field headers table<string, string>
---@field body string

---Parses `curl -I` like output into a table
---@param input string
---@return CurlReturn
local function parse_curl_like(input)
  local lines = strings.split(input, "\n")
  ---@type string,string,string
  local version, status_str, status_text = lines[1]:match("HTTP/(%S+) (%d+) (.*)")
  assert(version and status_str and status_text, "Could not parse HTTP status line: " .. tostring(lines[1]))
  local status = assert(tonumber(status_str), "Could not parse HTTP version: " .. tostring(status_str))

  local headers = {}
  --- After parsing all headers, lines[i] will be a blank line, after which will appear the body
  local i = 2
  while i <= #lines do
    local line = lines[i]
    if line:match("^%s*$") then break end
    local key, value = line:match("^(%S+)%s*:%s*(.*)$")
    assert(key, "Could not parse HTTP headers: " .. tostring(line))
    headers[key] = value
    i = i + 1
  end
  return { ---@type CurlReturn
    http_version = version,
    status = status,
    status_text = status_text,
    ok = status >= 200 and status <= 299,
    headers = headers,
    body = table.concat(lines, "\n", i + 1),
  }
end

---@param stdout string
---@return boolean changed
local function set_notifications(stdout)
  local res = parse_curl_like(stdout) --- Parse gh output
  local errors = { [401] = "Unauthorized request", [403] = "Forbidden request", [422] = "Validation failure" }
  if errors[res.status] then
    notifs.error(errors[res.status])
    return false
  end
  -- Reduce the debounce duration if necessary
  local interval = tonumber(res.headers["X-Poll-Interval"])
  if interval then
    local dd = state.debounce_duration
    -- In the latter case, we should revert to the user's config
    state.debounce_duration = interval > dd and interval or M.default_debounce_duration
  end
  --- Note: a 304 response is ignored, as it doesn't change the stored value
  if not res.ok then return false end
  local count = assert(tonumber(res.body), "Invalid number format: " .. tostring(res.body))
  M.notification_count = count
  return true
end

-- Calls fn if enough time has passed s.t. the user is able to make a new request.
---@param fn fun(last_call: integer|nil)
---@return boolean
local function debounce(fn)
  if not state then return false end
  local debounce_ok_at = state.last_refresh and state.last_refresh + state.debounce_duration
  if debounce_ok_at and debounce_ok_at >= os.time() then return false end
  local last_refresh = state.last_refresh
  state.last_refresh = os.time()
  fn(last_refresh)
  return true
end

-- Makes a new get request to the notifications API, refreshing the state variables.
---@param if_changed? fun(count: integer): any?
---@param done? fun(): any?
M.refresh = function(if_changed, done)
  if_changed = if_changed or function() end
  done = done or function() end
  local ran = debounce(function(previous_last_refresh)
    local if_modified_since = previous_last_refresh and generate_last_modified(previous_last_refresh)

    local cmd = { "gh", "api", "notifications", "-i", "-t", "{{ len . }}" }
    if if_modified_since then cmd = gtable.merge(cmd, { "-H", "If-Modified-Since: " .. if_modified_since }) end

    local suc = spawn.async(cmd, function(stdout, _, reason)
      if reason ~= "exit" then return end -- died to a a signal, ignore
      local changed = set_notifications(stdout)
      if changed then if_changed(M.notification_count) end
      return done()
    end)
    if suc then return end -- handled in the callback
    notifs.error_once("Showing github notification count requires the gh command!")
    return done()
  end)
  if ran then return end -- handled async
  return done()
end

local function on_changed(count) ---@param count integer
  if count <= 0 then return end
  local notification
  local function open()
    if notification then notification.die() end -- Don't pass a reason because naughty's changes are too annoying
    return require("configuration.apps.open").browser("https://github.com/notifications")
  end
  notification = notifs.info(
    ("%d unread github notifications!"):format(count),
    { timeout = 10, actions = { ["open in browser"] = open } }
  )
end
local function handler()
  M.timer:stop() -- ensure it doesn't run again while we refresh
  M.refresh(on_changed, function()
    M.timer.timeout = state.debounce_duration -- use the newly calculated timeout value
    M.timer:start() -- wait for the next timeout duration
  end)
end
-- don't autostart because callback will start the timer
M.timer = gtimer.new({ callback = handler })
handler()
()
return M
