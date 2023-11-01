---@meta -- This file is a meta file. It's definitions/uses aren't real definitions/uses
---@diagnostic disable :unused-local The variables in this file are placeholders for the types. They are not used, nor are they intended to be used
---@diagnostic disable :missing-return The variables in this file are placeholders for the types. They are not used, nor are they intended to be used

---A table containing globals provided by AwesomeWM.
---This can/should be used to allow typing and intelisense.
local capi = { ---@diagnostic disable :undefined-global These are injected by AwesomeWM
  awesome = awesome, ---@type Awesome
  root = root, ---@type AwesomeRoot
  dbus = dbus, ---@type AwesomeDbus?
  keygrabber = keygrabber, ---@type AwesomeKeygrabber
  mousegrabber = mousegrabber, ---@type AwesomeMousegrabber
  mouse = mouse, ---@type AwesomeMouse
  screen = screen, ---@type AwesomeScreen
  button = button, ---@type AwesomeButton
  tag = tag, ---@type AwesomeTag
  window = window, ---@type AwesomeWindow
  drawable = drawable, ---@type AwesomeDrawable
  drawin = drawin, ---@type AwesomeDrawin
  client = client, ---@type AwesomeClient
  selection = selection, ---@type AwesomeSelection
  key = key, ---@type AwesomeKey
} ---@diagnostic enable :undefined-global

--- Don't continue past this!
--- The rest of this file is here only for typing and intelisense!
--- if true to avoid the error from code after return.
if true then return capi end

local types = {}
---@generic V
---@param V V
local function opt(V) end ---@return V | nil
local boolean = false ---@type boolean
local string = "" ---@type string
---@alias screen table|integer
---@alias AwesomeLayout { arrange: function, name: string, skip_gap: function, arrange: function?}
---@alias gears.surface userdata
---@alias CairoPattern userdata
---@alias exit_callback fun(type: "signal"|"exit", code: integer)
---@alias xkb_group 0|1|2|3
---@alias xprop_type string|number|boolean
---@alias xprop_type_str "string"|"number"|"boolean"
---@alias SignalName --- A list of signals. Likely incomplete. Meant to enable autocompletion
--- | string
--- | "debug::error"
--- | "debug::deprecation"
--- | "debug::index::miss"
--- | "debug::newindex::miss"
--- | "systray::update"
--- | "wallpaper_changed"
--- | "xkb::map_changed"
--- | "xkb::group_changed."
--- | "refresh"
--- | "startup"
--- | "exit"
--- | "screen::change"
--- | "spawn::canceled"
--- | "spawn::change"
--- | "spawn::completed"
--- | "spawn::initiated"
--- | "spawn::timeout"

---@class AwesomeSignalClass
types.AwesomeSignalClass = {
  ---@param signal SignalName
  add_signal = function(signal) end, ---@deprecated Use connect_signal without calling add_signal
  ---@param signal SignalName
  ---@param callback function
  connect_signal = function(signal, callback) end,
  ---@param signal SignalName
  ---@param callback function
  disconnect_signal = function(signal, callback) end,
  ---@param signal SignalName
  ---@param ... unknown
  emit_signal = function(signal, ...) end,
  instances = function() end, ---@return integer
  ---@param handler fun(self: AwesomeSignalClass, k: any)
  set_index_miss_handler = function(handler) end, --- Typically this shouldn't be used
  ---@param handler fun(self: AwesomeSignalClass, k: any, v: any)
  set_newindex_miss_handler = function(handler) end, --- Typically this shouldn't be used
}
---@class AwesomeSignalClassInstance used for connect_signal and disconnect_signal methods
types.AwesomeSignalClassInstance = {
  ---@param self AwesomeSignalClassInstance
  ---@param signal SignalName
  ---@param callback function
  connect_signal = function(self, signal, callback) end,
  ---@param self AwesomeSignalClassInstance
  ---@param signal SignalName
  ---@param callback function
  disconnect_signal = function(self, signal, callback) end,
  ---@param self AwesomeSignalClassInstance
  ---@param signal SignalName
  ---@param ... unknown
  emit_signal = function(self, signal, ...) end,
}

---@class Awesome
---@field unix_signal { [string]: integer?, [integer]: string? }
types.Awesome = {
  quit = function(code) end, ---@param code integer?
  exec = function(cmd) end, ---@param cmd string
  ---@param cmd string|string[]
  ---@param use_sn? boolean
  ---@param stdin? boolean
  ---@param stdout? boolean
  ---@param stderr? boolean
  ---@param exit_callback? exit_callback
  ---@param env? table<string, string>
  ---@return integer|string pid
  ---@return string? snid
  ---@return integer? stdin
  ---@return integer? stdout
  ---@return integer? stderr
  spawn = function(cmd, use_sn, stdin, stdout, stderr, exit_callback, env) end,
  restart = function() end,
  ---Note: these aren't possible to properly type, as the callback is different for each signal
  ---@param signal SignalName
  ---@param callback function
  connect_signal = function(signal, callback) end,
  ---Note: these aren't possible to properly type, as the callback is different for each signal
  ---@param signal SignalName
  ---@param callback function
  disconnect_signal = function(signal, callback) end,
  ---Note: these aren't possible to properly type, as the callback is different for each signal
  ---@param signal SignalName
  ---@param ... unknown?
  emit_signal = function(signal, ...) end,
  ---@param drawin userdata
  ---@param x number
  ---@param y number
  ---@param base_size number
  ---@param horiz boolean
  ---@param bg string
  ---@param revers boolean
  ---@param spacing number
  ---@param rows number
  ---@return number entries
  ---@return table parent
  systray = function(drawin, x, y, base_size, horiz, bg, revers, spacing, rows) end,
  ---@param name string
  ---@return gears.surface
  ---@return string error
  load_image = function(name) end, ---@nodiscard
  ---@param pixbuf userdata
  ---@return gears.surface
  pixbuf_to_surface = function(pixbuf) end, ---@nodiscard
  ---@param size integer
  set_preferred_icon_size = function(size) end,
  ---@param name string
  ---@param type xprop_type_str
  register_xproperty = function(name, type) end,
  ---@param name string
  ---@param value xprop_type
  set_xproperty = function(name, value) end,
  ---@param name string
  ---@return xprop_type?
  ---@nodiscard
  get_xproperty = function(name) end, ---Errors if not found
  ---@param num xkb_group
  xkb_set_layout_group = function(num) end,
  ---@nodiscard
  xkb_get_layout_group = function() end, ---@return xkb_group num
  ---@nodiscard
  xkb_get_group_names = function() end, ---@return string
  ---@param class string
  ---@param name string
  ---@return string?
  ---@return xprop_type?
  ---@nodiscard
  xrdb_get_value = function(class, name) end,
  ---@param pid integer
  ---@param sig string|integer
  ---@return boolean
  kill = function(pid, sig) end,
  sync = function() end,
  ---@param input string?
  ---@return string? keysym
  ---@return string? printsymbol
  ---@nodiscard
  _get_key_name = function(input) end,
  startup = boolean,
  version = string,
  release = string,
  conffile = string,
  startup_errors = opt(string),
  composite_manager_running = boolean,
  hostname = string,
  themes_path = string,
  icon_path = string,
}
function types.Awesome:__index(k) end
function types.Awesome:__newindex(k, v) end

---@class AwesomeRoot
types.AwesomeRoot = {
  cursor = function(cursor_name) end, ---@param cursor_name string  A X cursor name.
  ---@param event_type "key_press"| "key_release"| "button_press"| "button_release"| "motion_notify"
  ---@param detail string|integer|boolean depends on event_type
  ---@param x number? Only used for motion_notify
  ---@param y number? Only used for motion_notify
  fake_input = function(event_type, detail, x, y) end,
  drawins = function() end, ---@return AwesomeDrawin[]
  content = function() end,
  ---@return number x
  ---@return number y
  ---@nodiscard
  size = function() end,
  ---@return number x
  ---@return number y
  ---@nodiscard
  size_mm = function() end,
  ---@nodiscard
  tags = function() end, ---@return AwesomeTagInstance[]
  set_index_miss_handler = function(handler) end, ---@param handler fun(self: AwesomeSignalClass, k: any)
  set_call_handler = function(handler) end, ---@param handler fun(self: AwesomeSignalClass, ...: unknown)
  set_newindex_miss_handler = function(handler) end, ---@param handler fun(self: AwesomeSignalClass, k: any, v: any)
  ---@param button_table AwesomeButton[]? An array of mouse button bindings objects, or nothing
  ---@nodiscard
  buttons = function(button_table) end, ---@return AwesomeButton[]?
  ---@param keys_array AwesomeKey[]? An array of key binding objects, or nothing
  keys = function(keys_array) end, ---@return AwesomeKey[]?
  ---@param pattern CairoPattern
  wallpaper = function(pattern) end, ---@return CairoPattern?
}
function types.AwesomeRoot:__index(k) end
function types.AwesomeRoot:__newindex(k, v) end

---@class AwesomeDbus
---@field request_name fun()
---@field release_name fun()
---@field add_match fun()
---@field remove_match fun()
---@field connect_signal fun()
---@field disconnect_signal fun()
---@field emit_signal fun()
---@field __index fun()
---@field __newindex fun()

---@class AwesomeKeygrabber
---@class AwesomeMousegrabber
---@class AwesomeMouse
---@field current_wibox table? wibox
---@class AwesomeScreen :AwesomeSignalClass
---@field primary AwesomeScreenInstance?

---@class AwesomeScreenInstance :AwesomeSignalClassInstance
---@field tags AwesomeTagInstance[]
---@field clients AwesomeClientInstance[]
---@field selected_tags AwesomeTagInstance[]
---@field selected_tag AwesomeTagInstance?
---@field geometry { height: number, width: number, x: number, y: number }

---@class AwesomeButton :AwesomeSignalClass
---@class AwesomeWindow
---@class AwesomeDrawable :AwesomeSignalClass
---@class AwesomeDrawin :AwesomeSignalClass
---@class AwesomeTag :AwesomeSignalClass

---@class AwesomeTagInstance :AwesomeSignalClassInstance
---@field layout AwesomeLayout
---@field view_only fun(self: AwesomeTagInstance)
---@field index integer
---@field screen AwesomeScreenInstance?

---@class AwesomeClientInstance :AwesomeSignalClassInstance
---@field floating boolean
---@field valid boolean
---@field maximized boolean
---@field above boolean
---@field below boolean
---@field ontop boolean
---@field sticky boolean
---@field maximized_horizontal boolean
---@field maximized_vertical boolean
---@field hidden boolean
---@field border_width integer
---@field instance string
---@field name string
---@field class string
---@field shape gears.shape
---@field move_to_tag fun(self: AwesomeClientInstance, tag: AwesomeTagInstance)
---@field toggle_tag fun(self: AwesomeClientInstance, tag: AwesomeTagInstance)
---@field raise fun(self: AwesomeClientInstance)
---@field jump_to fun(self: AwesomeClientInstance)
---@field screen AwesomeScreenInstance?
---@field fullscreen boolean
---@field tags fun(self: AwesomeClientInstance, tags?: AwesomeTagInstance[]): AwesomeTagInstance[]

---@class AwesomeClient :AwesomeSignalClass
---@field focus AwesomeClientInstance?
---@field get fun(screen: screen?, stacked: boolean?): AwesomeClientInstance[]

---@class AwesomeKey :AwesomeSignalClass

---@alias selectionFunc fun(): string
---@alias AwesomeSelection { selection: selectionFunc } | selectionFunc
---moved under selection.selection in v5

types = nil -- remove references to above tables
collectgarbage("collect") -- Encourage lua to remove the above tables
return capi
