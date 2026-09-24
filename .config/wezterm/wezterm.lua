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
-- wezterm.GLOBAL survives config reloads (but not a wezterm restart, so
-- launching wezterm always starts you back on 'Native').
local main_font = wezterm.GLOBAL.main_font or 'Native'

config.font = wezterm.font_with_fallback {
  main_font,
  'Menlo',
  'Noto Color Emoji',
}

-- Swap the main font and reload so the change takes effect immediately.
local function swap_font(family)
  return wezterm.action_callback(function(window, pane)
    wezterm.GLOBAL.main_font = family
    window:perform_action(wezterm.action.ReloadConfiguration, pane)
    window:toast_notification('wezterm', 'Main font: ' .. family, nil, 2000)
  end)
end

-- Ctrl-Cmd-Shift-9 -> Anoxia, Ctrl-Cmd-Shift-8 -> Native.
-- Each is bound twice: depending on keyboard layout handling wezterm may
-- report the shifted character ('(' / '*') instead of the digit.
local FONT_KEYS = {
  { keys = { '9', '(' }, family = 'Anoxia' },
  { keys = { '8', '*' }, family = 'Native' },
}

config.keys = config.keys or {}
for _, entry in ipairs(FONT_KEYS) do
  for _, key in ipairs(entry.keys) do
    table.insert(config.keys, {
      key = key,
      mods = 'CTRL|CMD|SHIFT',
      action = swap_font(entry.family),
    })
  end
end

-- Finally, return the configuration to wezterm:
return config
