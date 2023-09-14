local gshape = require("gears.shape")
local mat_colors = require("theme.mat-colors")
local theme_assets = require("beautiful.theme_assets")
local dpi = require("beautiful").xresources.apply_dpi
local compat = require("util.compat")
local icons = require("theme.icons")

local function do_theme(theme, theme_dir)
  theme = theme or {}
  theme.icons = icons.DIR .. "/"

  -- Colors Pallets
  theme.fg = mat_colors.hue_blue
  theme.accent = mat_colors.deep_orange
  theme.background = mat_colors.grey

  theme.font = "Roboto medium 10"
  theme.title_font = "Roboto medium 14"

  theme.fg_normal = mat_colors.white
  theme.fg_focus = theme.fg.hue_900
  theme.fg_urgent = theme.accent.hue_900

  theme.bg_normal = theme.background.hue_900
  theme.bg_focus = "#5a5a5a"
  theme.bg_urgent = theme.accent.hue_900
  theme.bg_systray = theme.bg_normal

  -- Borders
  theme.useless_gap = dpi(0)
  theme.border_width = dpi(2)
  compat.beautiful.set_border_normal(theme, theme.bg_normal)
  compat.beautiful.set_border_focus(theme, theme.fg_focus)
  theme.border_width = dpi(2)
  theme.border_marked = "#CC9393"

  -- Menu
  theme.menu_height = dpi(16)
  theme.menu_width = dpi(160)

  -- Tooltips
  theme.tooltip_bg = "#232323"
  --theme.tooltip_border_color = '#232323'
  theme.tooltip_border_width = 0
  theme.tooltip_shape = function(cr, w, h)
    gshape.rounded_rect(cr, w, h, dpi(6))
  end

  -- Layout
  theme.layout_tile = icons.layout.tile
  theme.layout_tileleft = icons.layout.tileleft
  theme.layout_spiral = icons.layout.spiral
  theme.layout_dwindle = icons.layout.dwindle
  theme.layout_tilebottom = icons.layout.tilebottom
  theme.layout_tiletop = icons.layout.tiletop
  theme.layout_fairh = icons.layout.fairh
  theme.layout_fairv = icons.layout.fairv
  theme.layout_floating = icons.layout.floating
  theme.layout_magnifier = icons.layout.magnifier

  theme.layout_cornerne = icons.layout.cornerne
  theme.layout_cornernw = icons.layout.cornernw
  theme.layout_cornersw = icons.layout.cornersw
  theme.layout_cornerse = icons.layout.cornerse
  theme.layout_fullscreen = icons.layout.fullscreen
  theme.layout_max = icons.layout.max

  -- Taglist
  theme.taglist_bg_empty = theme.bg_normal
  theme.taglist_bg_occupied = theme.bg_normal
  theme.taglist_bg_urgent = "linear:0,0:"
    .. dpi(40)
    .. ",0:0,"
    .. theme.accent.hue_500
    .. ":0.08,"
    .. theme.accent.hue_500
    .. ":0.08,"
    .. theme.bg_normal
    .. ":1,"
    .. theme.bg_normal
  theme.taglist_bg_focus = "linear:0,0:"
    .. dpi(40)
    .. ",0:0,"
    .. theme.fg.hue_900
    .. ":0.08,"
    .. theme.fg.hue_900
    .. ":0.08,"
    .. theme.bg_normal
    .. ":1,"
    .. theme.bg_normal
  local taglist_square_size = dpi(4)
  theme.taglist_squares_sel = theme_assets.taglist_squares_sel(taglist_square_size, theme.fg_normal)
  theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(taglist_square_size, theme.fg_normal)

  -- Tasklist
  theme.tasklist_font = "Roboto medium 11"
  theme.tasklist_bg_normal = theme.bg_normal
  theme.tasklist_bg_focus = "linear:0,0:0,"
    .. dpi(40)
    .. ":0,"
    .. theme.bg_normal
    .. ":0.95,"
    .. theme.bg_normal
    .. ":0.95,"
    .. theme.fg_normal
    .. ":1,"
    .. theme.fg_normal
  theme.tasklist_bg_urgent = theme.fg.hue_800
  theme.tasklist_fg_focus = "#DDDDDD"
  theme.tasklist_fg_urgent = theme.fg_normal
  theme.tasklist_fg_normal = "#AAAAAA"

  theme.icon_theme = "Papirus-Dark"

  -- Titlebar
  --- Define the image to load
  theme.titlebar_close_button_normal = icons.titlebar.window_close_normal
  theme.titlebar_close_button_focus = icons.titlebar.window_close

  theme.titlebar_minimize_button_normal = icons.titlebar.go_down
  theme.titlebar_minimize_button_focus = icons.titlebar.go_down

  theme.titlebar_maximized_button_normal_inactive = icons.titlebar.go_up
  theme.titlebar_maximized_button_focus_inactive = icons.titlebar.go_up
  theme.titlebar_maximized_button_normal_active = icons.titlebar.go_up
  theme.titlebar_maximized_button_focus_active = icons.titlebar.go_up
  theme.titlebar_bg_focus = theme.bg_normal
  theme.titlebar_bg_normal = theme.bg_normal
  ---Rofi Settings
  theme.rofi_bg = theme.bg_normal -- Normal background color
  theme.rofi_fg = theme.fg_normal -- Text color
  theme.rofi_active_background = theme.bg_focus -- The background color for selected

  theme.notification_margin = dpi(8)
  -- This *MUST* be defined, otherwise naughty.notify has some weird behavior when searching for icons without a given size.
  theme.notification_icon_size = dpi(24)
  theme.notification_shape = gshape.rounded_rect
  theme.notification_border_width = 0

  return theme
end

return do_theme
