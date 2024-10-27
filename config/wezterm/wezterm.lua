local wezterm = require 'wezterm'
local config = {}
local act = wezterm.action

config.default_prog = { 'nix-shell' }

config.color_scheme = 'One Dark (Gogh)'
config.disable_default_key_bindings = true
config.enable_kitty_keyboard = true

config.text_blink_rate = 0
config.tab_bar_at_bottom = true

config.font_size = 14

config.leader = { key = 't', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom 'PrimarySelection' },
  { key = 'c', mods = 'CTRL', action = wezterm.action.CopyTo 'ClipboardAndPrimarySelection' },

  {
    key = 't',
    mods = 'LEADER',
    action = act.SpawnTab 'CurrentPaneDomain',
  },
  { key = 'l', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  { key = 'y', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  {
    key = 'p',
    mods = 'LEADER',
    action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'P',
    mods = 'LEADER',
    action = act.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'n',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Left',
  },
  {
    key = 'i',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Right',
  },
  {
    key = 'u',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Up',
  },
  {
    key = 'e',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Down',
  },
}

return config
