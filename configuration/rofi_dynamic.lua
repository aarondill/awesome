local awful = require("awful")
local require = require("util.rel_require")

local beautiful = require("beautiful")
local config_file_dir = require(..., "apps.conffile_dir") ---@module "configuration.apps.conffile_dir"
local strings = require("util.strings")
local write_async = require("util.file.write_async")

---@param p string?
---@param v string?
---@param quote boolean?
---@param suffix string?
---@return string?
local function prop(p, v, quote, suffix)
  if not p or not v then return nil end
  suffix = suffix or ""
  local format = quote and '%s: "%s%s"' or "%s: %s%s"
  -- Add new property
  return ("\t" .. format .. ";"):format(p, v, suffix)
end

local screen_h = awful.screen.focused().geometry.height
local top_height = beautiful.top_panel_height or 0
local gap = beautiful.useless_gap or 0 -- Leave a small gap. Not Dynamic!
local panel_height = screen_h - top_height - gap -- height for rofi window

local conf = strings.line2str({
  "// This file is automatically generated. Do not edit",
  "* {",
  prop("bg-var", beautiful.rofi_bg),
  prop("fg-var", beautiful.rofi_fg),
  prop("active-background-var", beautiful.rofi_active_background),
  prop("font-var", beautiful.font, true),
  prop("panel-height", panel_height, false, "px"),
  "}",
  "// vim" .. ":ft=css commentstring=//%s:", -- hack to stop vim from processing this modeline here
})

write_async(config_file_dir .. "/rofi/dynamic.rasi", conf) -- this file should be ignored
