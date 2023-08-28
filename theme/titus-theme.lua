local mat_colors = require("theme.mat-colors")

local function do_theme(theme, theme_dir)
  theme.icons = theme_dir .. "/icons/"
  theme.font = "Roboto medium 10"

  -- Colors Pallets

  -- Primary
  theme.primary = mat_colors.indigo
  theme.primary.hue_500 = "#003f6b"
  -- Accent
  theme.accent = mat_colors.pink

  -- Background
  theme.background = mat_colors.blue_grey

  theme.background.hue_800 = "#192933"
  theme.background.hue_900 = "#121e25"
end

return do_theme
