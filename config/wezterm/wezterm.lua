local wezterm = require 'wezterm'

return {
  font = wezterm.font 'Monospace',
  font_size = 10,
  color_scheme = 'Catppuccin Mocha',
  enable_scroll_bar = true,
  default_cursor_style = 'SteadyBar',
  front_end = 'WebGpu',
  hide_tab_bar_if_only_one_tab = false,
  command_palette_font_size = 12.0,
  command_palette_fg_color = '#cdd6f4',
  command_palette_bg_color = '#11111b',
  window_decorations = 'INTEGRATED_BUTTONS|RESIZE',
  integrated_title_button_style = 'Gnome',
  integrated_title_buttons = { 'Close' },
  integrated_title_button_color = '#f38ba8',
  window_padding = {
    left = 10,
    right = 10,
    top = 20,
    bottom = 10,
  },
  window_frame = {
    font = wezterm.font { family = 'Ubuntu', weight = 'Bold' },
    font_size = 10.0,
    inactive_titlebar_bg = '#1e1e2e',
    active_titlebar_bg = '#11111b',
    inactive_titlebar_border_bottom = '#313244',
    active_titlebar_border_bottom = '#313244',
    button_bg = '#313244',
    button_hover_bg = '#45475a',
  },
  colors = {
    tab_bar = {
      background = '#11111b',
      active_tab = {
        bg_color = '#cba6f7',
        fg_color = '#11111b',
      },
      inactive_tab = {
        bg_color = '#181825',
        fg_color = '#cdd6f4',
      },
      inactive_tab_hover = {
        bg_color = '#1e1e2e',
        fg_color = '#cdd6f4',
      },
      new_tab = {
        bg_color = '#313244',
        fg_color = '#cdd6f4',
      },
      new_tab_hover = {
        bg_color = '#45475a',
        fg_color = '#cdd6f4',
      },
    },
  },
}
