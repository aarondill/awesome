---@class Awesome
---@field quit fun(): nil
---@field exec fun(): nil
---@field spawn fun(): nil
---@field restart fun(): nil
---@field connect_signal fun(): nil
---@field disconnect_signal fun(): nil
---@field emit_signal fun(): nil
---@field systray fun(): nil
---@field load_image fun(): nil
---@field pixbuf_to_surface fun(): nil
---@field set_preferred_icon_size fun(): nil
---@field register_xproperty fun(): nil
---@field set_xproperty fun(): nil
---@field get_xproperty fun(): nil
---@field xkb_set_layout_group fun(): nil
---@field xkb_get_layout_group fun(): nil
---@field xkb_get_group_names fun(): nil
---@field xrdb_get_value fun(): nil
---@field kill fun(): nil
---@field sync fun(): nil
---@field unix_signal { [string]: integer?, [integer]: string? }
---@field _get_key_name fun(): nil
---@field __index fun(): nil
---@field __newindex fun(): nil

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
