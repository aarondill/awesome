local filesystem = require("gears.filesystem")
local mat_colors = require("theme.mat-colors")
local theme_dir = filesystem.get_configuration_dir() .. "/theme"
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local theme = {}
theme.icons = theme_dir .. "/icons/"
theme.font = "Roboto medium 10"

-- Colors Pallets

-- Primary
theme.primary = mat_colors.deep_orange

-- Accent
theme.accent = mat_colors.pink

-- Background
theme.background = mat_colors.grey

local awesome_overrides = function(theme)
	theme.dir = os.getenv("HOME") .. "/.config/awesome/theme"
	theme.icons = theme.dir .. "/icons/"
	--theme.wallpaper = theme.dir .. '/wallpapers/DarkCyan.png'
	theme.wallpaper = "#e0e0e0"
	theme.font = "Roboto medium 10"
	theme.title_font = "Roboto medium 14"

	theme.fg_normal = "#ffffffde"
	theme.fg_focus = "#e4e4e4"
	theme.fg_urgent = "#CC9393"

	theme.bat_fg_critical = "#232323"

	theme.bg_normal = theme.background.hue_800
	theme.bg_focus = "#5a5a5a"
	theme.bg_urgent = "#3F3F3F"
	theme.bg_systray = theme.background.hue_800

	-- Borders
	theme.useless_gap = dpi(0)
	theme.border_width = dpi(2)
	theme.border_normal = theme.background.hue_800
	theme.border_focus = theme.primary.hue_300
	theme.border_marked = "#CC9393"

	-- Menu
	theme.menu_height = dpi(16)
	theme.menu_width = dpi(160)

	-- Titlebar
	theme.titlebar_close_button_normal = theme.icons .. "titlebar/close_normal.png"
	theme.titlebar_close_button_focus = theme.icons .. "titlebar/close_focus.png"

	theme.titlebar_minimize_button_normal = theme.icons .. "titlebar/minimize_normal.png"
	theme.titlebar_minimize_button_focus = theme.icons .. "titlebar/minimize_focus.png"

	theme.titlebar_ontop_button_normal_inactive = theme.icons .. "titlebar/ontop_normal_inactive.png"
	theme.titlebar_ontop_button_focus_inactive = theme.icons .. "titlebar/ontop_focus_inactive.png"
	theme.titlebar_ontop_button_normal_active = theme.icons .. "titlebar/ontop_normal_active.png"
	theme.titlebar_ontop_button_focus_active = theme.icons .. "titlebar/ontop_focus_active.png"

	theme.titlebar_sticky_button_normal_inactive = theme.icons .. "titlebar/sticky_normal_inactive.png"
	theme.titlebar_sticky_button_focus_inactive = theme.icons .. "titlebar/sticky_focus_inactive.png"
	theme.titlebar_sticky_button_normal_active = theme.icons .. "titlebar/sticky_normal_active.png"
	theme.titlebar_sticky_button_focus_active = theme.icons .. "titlebar/sticky_focus_active.png"

	theme.titlebar_floating_button_normal_inactive = theme.icons .. "titlebar/floating_normal_inactive.png"
	theme.titlebar_floating_button_focus_inactive = theme.icons .. "titlebar/floating_focus_inactive.png"
	theme.titlebar_floating_button_normal_active = theme.icons .. "titlebar/floating_normal_active.png"
	theme.titlebar_floating_button_focus_active = theme.icons .. "titlebar/floating_focus_active.png"

	theme.titlebar_maximized_button_normal_inactive = theme.icons .. "titlebar/maximized_normal_inactive.png"
	theme.titlebar_maximized_button_focus_inactive = theme.icons .. "titlebar/maximized_focus_inactive.png"
	theme.titlebar_maximized_button_normal_active = theme.icons .. "titlebar/maximized_normal_active.png"
	theme.titlebar_maximized_button_focus_active = theme.icons .. "titlebar/maximized_focus_active.png"

	-- Tooltips
	theme.tooltip_bg = "#232323"
	--theme.tooltip_border_color = '#232323'
	theme.tooltip_border_width = 0
	theme.tooltip_shape = function(cr, w, h)
		gears.shape.rounded_rect(cr, w, h, dpi(6))
	end

	-- Layout
	theme.layout_tile = theme.icons .. "layouts/tile-right.svg"
	theme.layout_tileleft = theme.icons .. "layouts/tile-left.svg"
	theme.layout_spiral = theme.icons .. "layouts/spiral.svg"
	theme.layout_dwindle = theme.icons .. "layouts/dwindle.svg"
	theme.layout_tilebottom = theme.icons .. "layouts/tile-bottom.svg"
	theme.layout_tiletop = theme.icons .. "layouts/tile-top.svg"
	theme.layout_fairh = theme.icons .. "layouts/fair-horizontal.svg"
	theme.layout_fairv = theme.icons .. "layouts/fair.svg"
	theme.layout_floating = theme.icons .. "layouts/floating.svg"
	theme.layout_magnifier = theme.icons .. "layouts/magnifier.svg"

	theme.layout_cornerne = theme.icons .. "layouts/cornerne.svg"
	theme.layout_cornernw = theme.icons .. "layouts/cornernw.svg"
	theme.layout_cornersw = theme.icons .. "layouts/cornersw.svg"
	theme.layout_cornerse = theme.icons .. "layouts/cornerse.svg"
	theme.layout_fullscreen = theme.icons .. "layouts/fullscreen.svg"
	theme.layout_max = theme.icons .. "layouts/max.svg"

	-- Taglist
	theme.taglist_bg_empty = theme.background.hue_800
	theme.taglist_bg_occupied = theme.background.hue_800
	theme.taglist_bg_urgent = "linear:0,0:"
		.. dpi(40)
		.. ",0:0,"
		.. theme.accent.hue_500
		.. ":0.08,"
		.. theme.accent.hue_500
		.. ":0.08,"
		.. theme.background.hue_800
		.. ":1,"
		.. theme.background.hue_800
	theme.taglist_bg_focus = "linear:0,0:"
		.. dpi(40)
		.. ",0:0,"
		.. theme.primary.hue_500
		.. ":0.08,"
		.. theme.primary.hue_500
		.. ":0.08,"
		.. theme.background.hue_800
		.. ":1,"
		.. theme.background.hue_800

	-- Tasklist
	theme.tasklist_font = "Roboto medium 11"
	theme.tasklist_bg_normal = theme.background.hue_800
	theme.tasklist_bg_focus = "linear:0,0:0,"
		.. dpi(40)
		.. ":0,"
		.. theme.background.hue_800
		.. ":0.95,"
		.. theme.background.hue_800
		.. ":0.95,"
		.. theme.fg_normal
		.. ":1,"
		.. theme.fg_normal
	theme.tasklist_bg_urgent = theme.primary.hue_800
	theme.tasklist_fg_focus = "#DDDDDD"
	theme.tasklist_fg_urgent = theme.fg_normal
	theme.tasklist_fg_normal = "#AAAAAA"

	theme.icon_theme = "Papirus-Dark"

	--Client
	theme.border_width = dpi(2)
	theme.border_focus = theme.primary.hue_500
	theme.border_normal = theme.background.hue_800
end
return {
	theme = theme,
	awesome_overrides = awesome_overrides,
}
