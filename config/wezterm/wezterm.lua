local wezterm = require 'wezterm'
local config = {}
local act = wezterm.action

config.window_close_confirmation = 'NeverPrompt'
config.color_scheme = 'OneHalfDark'
config.disable_default_key_bindings = true
config.enable_kitty_keyboard = true

config.default_cursor_style = 'SteadyBlock'
config.tab_bar_at_bottom = true

config.font_size = 13

config.leader = { key = 't', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard' },
  {
    key = 'c',
    mods = 'CTRL',
    action = wezterm.action_callback(function(window, pane)
        selection_text = window:get_selection_text_for_pane(pane)
        is_selection_active = string.len(selection_text) ~= 0
        if is_selection_active then
            window:perform_action(wezterm.action.CopyTo('ClipboardAndPrimarySelection'), pane)
        else
            window:perform_action(wezterm.action.SendKey{ key='c', mods='CTRL' }, pane)
        end
    end),
  },

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
  {
    key = 'w',
    mods = 'LEADER',
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },
}

return config
