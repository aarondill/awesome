---@alias gears.surface unknown

---@alias exit_callback fun(type: "signal"|"exit", code: integer)
---@alias xkb_group 0|1|2|3
---@alias xprop_type string|number|boolean
---@alias xprop_type_str "string"|"number"|"boolean"

---@class Awesome
---@field quit fun(code: integer?)
---@field exec fun(cmd: string)
---@field spawn fun(cmd: string|string[], use_sn?: boolean, stdin?: boolean, stdout?: boolean, stderr?: boolean, exit_callback?: exit_callback, env?: table<string, string>): pid: integer|string, snid: string?, stdin: integer?, stdout: integer?, stderr: integer?
---@field restart fun()
---Note: these aren't possible to properly type, as the callback is different for each signal
---@field connect_signal fun(signal: string, callback: fun())
---@field disconnect_signal fun(signal: string, callback: fun())
---@field emit_signal fun(signal: string, ...?: unknown)
---@field systray fun(drawin: userdata, x: number, y: number, base_size: number, horiz: boolean?, bg: string, revers: boolean?, spacing: number, rows: number): entries: number, parent: table
---@field load_image fun(name: string): gears.surface, error: string
---@field pixbuf_to_surface fun(pixbuf: userdata): gears.surface
---@field set_preferred_icon_size fun(size: integer)
---@field register_xproperty fun(name: string, type:  xprop_type_str)
---@field set_xproperty fun(name: string, value: xprop_type)
---@field get_xproperty fun(name: string): xprop_type? Errors if not found
---@field xkb_set_layout_group fun(num: xkb_group|integer) --- Note: the signature allows integer, but this is just for convenience.
---@field xkb_get_layout_group fun(): num: xkb_group
---@field xkb_get_group_names fun(): string
---@field xrdb_get_value fun(class: string, name: string): string?
---@field kill fun(pid: integer, sig: string|integer): boolean
---@field sync fun()
---@field unix_signal { [string]: integer?, [integer]: string? }
---@field _get_key_name fun(input: string?): keysym: string?, printsymbol: string?
--@field __index fun(): nil
--@field __newindex fun(): nil

---@class AwesomeRoot
---@field cursor fun(): nil
---@field fake_input fun(): nil
---@field drawins fun(): nil
---@field content fun(): nil
---@field size fun(): nil
---@field size_mm fun(): nil
---@field tags fun(): nil
---@field set_index_miss_handler fun(): nil
---@field set_call_handler fun(): nil
---@field set_newindex_miss_handler fun(): nil
---@field _buttons fun(): nil
---@field _keys fun(): nil
---@field _wallpaper fun(): nil
---@field __index fun(): nil
---@field __newindex fun(): nil

---@class AwesomeDbus
---@field request_name fun(): nil
---@field release_name fun(): nil
---@field add_match fun(): nil
---@field remove_match fun(): nil
---@field connect_signal fun(): nil
---@field disconnect_signal fun(): nil
---@field emit_signal fun(): nil
---@field __index fun(): nil
---@field __newindex fun(): nil

---@class AwesomeKeygrabber
---@class AwesomeMousegrabber
---@class AwesomeMouse
---@class AwesomeScreen
---@class AwesomeButton
---@class AwesomeTag
---@class AwesomeWindow
---@class AwesomeDrawable
---@class AwesomeDrawin
---@class AwesomeClient

---@alias selectionFunc fun(): string
---moved under selection.selection in v5
---@alias AwesomeSelection {selection: selectionFunc} | selectionFunc

return { ---@diagnostic disable :undefined-global These are injected by AwesomeWM
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
} ---@diagnostic enable :undefined-global
