-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

config.font_size = 13.25
config.color_scheme = 'OlexTerminal'

-- Tab bar
config.hide_tab_bar_if_only_one_tab = true

config.window_frame = {
  font = wezterm.font { family = 'Native' },
  font_size = 12.5,
}

-- Window Padding
config.window_padding = {
  left = 1,
  right = 1,
  top = 0,
  bottom = 0,
}

-- Main font is swappable at runtime via the keybindings below.
local FALLBACKS = { 'Menlo', 'Noto Color Emoji' }

local function font_stack(family)
  local stack = { family }
  for _, f in ipairs(FALLBACKS) do
    table.insert(stack, f)
  end
  return wezterm.font_with_fallback(stack)
end

config.font = font_stack 'Native'

-- Swap the main font for the focused window. set_config_overrides applies
-- immediately, so there's no config reload involved -- which matters because
-- action_callback handlers are named positionally (user-defined-0, -1, ...)
-- from the order they're created during config evaluation. Reloading
-- re-evaluates the file and re-derives those names, breaking the bindings
-- already stored in the key table.
local function swap_font(family)
  return wezterm.action_callback(function(window, _pane)
    local overrides = window:get_config_overrides() or {}
    overrides.font = font_stack(family)
    window:set_config_overrides(overrides)
    window:toast_notification('wezterm', 'Main font: ' .. family, nil, 2000)
  end)
end

-- Ctrl-Cmd-Shift-9 -> Anoxia, Ctrl-Cmd-Shift-8 -> Native.
-- Each is bound twice: depending on keyboard layout handling wezterm may
-- report the shifted character ('(' / '*') instead of the digit.
config.keys = {
  { key = '9', mods = 'CTRL|CMD|SHIFT', action = swap_font 'Anoxia' },
  { key = '(', mods = 'CTRL|CMD|SHIFT', action = swap_font 'Anoxia' },
  { key = '8', mods = 'CTRL|CMD|SHIFT', action = swap_font 'Native' },
  { key = '*', mods = 'CTRL|CMD|SHIFT', action = swap_font 'Native' },
}

-- Finally, return the configuration to wezterm:
return config
