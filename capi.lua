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
  screen = screen, ---@type AwesomeScreen|AwesomeScreenIterator
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
---@alias screen AwesomeScreenInstance|integer
---@alias AwesomeGeometry { height: number, width: number, x: number, y: number }
---@alias AwesomePosition { x: number,  y: number }
---@alias AwesomeLayout { arrange: function, name: string, skip_gap: function, arrange: function?}
---@alias CairoPattern userdata
---@alias CairoSurface userdata
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
---@class gears.surface :userdata
---@field finish fun()
---@alias awful.key table
---@alias awful.button table
---@alias gears.color |string A hexadecimal color code, such as "#ff0000" for red.
---|string A color name, such as "red".
---|table A gradient table.
---|CairoPattern Any valid Cairo pattern.
---|CairoPattern A texture build from an image by gears.color.create_png_pattern

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
---@field emit_signal fun(self: AwesomeSignalClassInstance, name: SignalName, ...: unknown) Emit a signal.
---@field connect_signal fun(self: AwesomeSignalClassInstance, name: SignalName, func: fun(...: unknown): any) Connect to a signal.
---@field weak_connect_signal fun(self: AwesomeSignalClassInstance, name: SignalName, func: fun(...: unknown): any) Connect to a signal weakly.
---@field disconnect_signal fun(self: AwesomeSignalClassInstance, name: SignalName, func: fun(...: unknown): any) Disconnect from a signal.

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
  ---@param path string
  ---@return gears.surface
  pixbuf_to_surface = function(pixbuf, path) end, ---@nodiscard
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
---@field coords fun(coords_table?: AwesomePosition, silent?: boolean): {[integer]: boolean, x: number, y: number}
---@field screen AwesomeScreenInstance
---@field current_wibox table? wibox
---@field current_client AwesomeClientInstance?

---@alias AwesomeScreenIterator fun(_: nil, prev?: AwesomeScreenInstance):AwesomeScreenInstance?
---@class AwesomeScreen :AwesomeSignalClass
---@field primary AwesomeScreenInstance?
---@field [integer] AwesomeScreenInstance?
---@field [AwesomeScreenInstance] AwesomeScreenInstance

---@class AwesomeScreenInstance :AwesomeSignalClassInstance
---@field valid boolean
---@field index integer
---@field tags AwesomeTagInstance[]
---@field clients AwesomeClientInstance[]
---@field selected_tags AwesomeTagInstance[]
---@field selected_tag AwesomeTagInstance?
---@field geometry AwesomeGeometry
---@field workarea AwesomeGeometry

---@class AwesomeButton :AwesomeSignalClass
---@class AwesomeWindow
---@class AwesomeDrawable :AwesomeSignalClass
---@class AwesomeDrawin :AwesomeSignalClass
---@class AwesomeTag :AwesomeSignalClass

---@class AwesomeTagInstance :AwesomeSignalClassInstance
---@field name string
---@field layout AwesomeLayout
---@field layouts AwesomeLayout[]
---@field view_only fun(self: AwesomeTagInstance)
---@field index integer
---@field screen AwesomeScreenInstance?
---@field gap integer
---@field clients fun(self: AwesomeTagInstance, clients:AwesomeClientInstance[]?): AwesomeClientInstance[]

---@alias AwesomeClientType 'desktop'|'dock'|'splash'|'dialog'|'menu'|'toolbar'|'utility'|'dropdown_menu'|'popup_menu'|'notification'|'combo'|'dnd'|'normal' The window type.
---@class AwesomeClientInstance :AwesomeSignalClassInstance
---@field above boolean The client is above normal windows.
---@field active boolean Return true if the client is active (has focus). (Read only)
---@field below boolean The client is below normal windows.
---@field border_color gears.color? The client border color.
---@field border_width integer? The client border width.
---@field buttons table Get or set mouse buttons bindings for a client.
---@field class string The client class. (Read only)
---@field client_shape_bounding CairoSurface The client's bounding shape as set by the program as a (native) cairo surface. (Read only)
---@field client_shape_clip CairoSurface The client's clip shape as set by the program as a (native) cairo surface. (Read only)
---@field content CairoSurface A cairo surface for the client window content. (Read only)
---@field dockable boolean If the client is dockable.
---@field first_tag AwesomeTagInstance? The first tag of the client. (Read only)
---@field floating boolean The client floating state.
---@field focusable boolean True if the client can receive the input focus.
---@field fullscreen boolean The client is fullscreen or not.
---@field group_window integer Window identification unique to a group of windows. (Read only)
---@field height integer The height of the client.
---@field hidden boolean Define if the client must be hidden (Never mapped, invisible in taskbar).
---@field icon CairoSurface The client icon as a surface.
---@field icon_name string The client name when iconified. (Read only)
---@field icon_sizes table The available sizes of client icons. (Read only)
---@field immobilized_horizontal boolean Is the client immobilized horizontally? (Read only)
---@field immobilized_vertical boolean Is the client immobilized vertically? (Read only)
---@field instance string The client instance. (Read only)
---@field is_fixed boolean Return if a client has a fixed size or not. (Read only)
---@field keys table Get or set keys bindings for a client.
---@field leader_window integer Identification unique to windows spawned by the same command. (Read only)
---@field machine string The machine the client is running on. (Read only)
---@field marked boolean If a client is marked or not.
---@field maximized boolean The client is maximized (horizontally and vertically) or not.
---@field maximized_horizontal boolean The client is maximized horizontally or not.
---@field maximized_vertical boolean The client is maximized vertically or not.
---@field minimized boolean Define if the client must be iconified (Only visible in taskbar).
---@field modal boolean Indicate if the client is modal.
---@field motif_wm_hints table The motif WM hints of the client. (Read only)
---@field name string The client title.
---@field ontop boolean The client is on top of every other windows.
---@field opacity number The client opacity.
---@field pid integer The client PID, if available. (Read only)
---@field requests_no_titlebar boolean If the client requests not to be decorated with a titlebar.
---@field role string The window role, if available. (Read only)
---@field screen AwesomeScreenInstance? Client screen.
---@field shape gears.shape Set the client shape.
---@field shape_bounding CairoSurface The client's bounding shape as set by awesome as a (native) cairo surface.
---@field shape_clip CairoSurface The client's clip shape as set by awesome as a (native) cairo surface.
---@field shape_input CairoSurface The client's input shape as set by awesome as a (native) cairo surface.
---@field size_hints table? A table with size hints of the client. (Read only)
---@field size_hints_honor boolean Honor size hints, e.g.
---@field skip_taskbar boolean True if the client does not want to be in taskbar.
---@field startup_id string The FreeDesktop StartId.
---@field sticky boolean Set the client sticky (Available on all tags).
---@field transient_for AwesomeClientInstance? The client the window is transient for. (Read only)
---@field type AwesomeClientType The window type. (Read only)
---@field urgent boolean Set to true when the client ask for attention.
---@field valid boolean If the client that this object refers to is still managed by awesome. (Read only)
---@field width integer The width of the client.
---@field window integer The X window id. (Read only)
---@field x integer The x coordinates.
---@field y integer The y coordinates.
---@field apply_size_hints fun(self: AwesomeClientInstance, width: integer, height: integer): (integer, integer) Apply size hints to a size.
---@field geometry fun(self: AwesomeClientInstance, geometry:AwesomeGeometry?): AwesomeGeometry Return or set client geometry.
---@field get_icon fun(self: AwesomeClientInstance, index): CairoSurface Get the client's n-th icon.
---@field get_transient_for_matching fun(self: AwesomeClientInstance, matcher: fun(c: AwesomeClientInstance): boolean): AwesomeClientInstance? Get a matching transient_for client (if any).
---@field is_transient_for fun(self: AwesomeClientInstance, c2: AwesomeClientInstance): AwesomeClientInstance? Is a client transient for another one?
---@field isvisible fun(self: AwesomeClientInstance): boolean Check if a client is visible on its screen.
-- If true then merge tags (select the client's first tag additionally) when
-- client and its first tag as arguments.
-- the client is not visible. If it is a function, it will be called with the
---@field jump_to fun(self: AwesomeClientInstance, merge: boolean|fun(self: AwesomeClientInstance, old: AwesomeTagInstance?)) Jump to the given client.
---@field kill fun(self: AwesomeClientInstance) Kill a client.
---@field lower fun(self: AwesomeClientInstance) Lower a client on bottom of others which are on the same layer.
---@field move_to_screen fun(self: AwesomeClientInstance, s?: AwesomeScreenInstance) Move a client to a screen. Note: if s is nil, default is next screen
---@field move_to_tag fun(self: AwesomeClientInstance, target: AwesomeTagInstance) Move a client to a tag.
---@field raise fun(self: AwesomeClientInstance) Raise a client on top of others which are on the same layer.
---@field relative_move fun(self: AwesomeClientInstance, x?: integer, y?: integer, w?: integer, h?: integer) Move/resize a client relative to current coordinates.
---@field struts fun(struts): table Return client struts (reserved space at the edge of the screen).
---@field swap fun(self: AwesomeClientInstance, c: AwesomeClientInstance) Swap a client with another one in global client list.
---@field tags fun(self: AwesomeClientInstance, tags?: AwesomeTagInstance[]): AwesomeTagInstance[] Access or set the client tags.
---@field to_selected_tags fun(self: AwesomeClientInstance) Find suitable tags for newly created clients.
---@field toggle_tag fun(self: AwesomeClientInstance, target: AwesomeTagInstance) Toggle a tag on a client.
---@field unmanage fun(self: AwesomeClientInstance) Stop managing a client.
---Introduced in V5: If running in V5 or greater, all of the below functions will be defined
---@field activate? fun(args: table) Activate (focus) a client. See the docs for the args table.
---@field append_keybinding? fun(self: AwesomeClientInstance, key: awful.key) Append a keybinding.
---@field remove_keybinding? fun(self: AwesomeClientInstance, key: awful.key) Remove a keybinding.
---@field append_mousebinding? fun(self: AwesomeClientInstance, button: awful.button) Append a mousebinding.
---@field remove_mousebinding? fun(self: AwesomeClientInstance, button: awful.button) Remove a mousebinding.
---@field grant? fun(self: AwesomeClientInstance, permission: string, context: string) Grant a permission for a client.
---@field deny? fun(self: AwesomeClientInstance, permission: string, context: string) Deny a permission for a client.
---@field to_primary_section? fun(self: AwesomeClientInstance) Move the client to the most significant layout position.
---@field to_secondary_section? fun(self: AwesomeClientInstance) Move the client to the least significant layout position.

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
