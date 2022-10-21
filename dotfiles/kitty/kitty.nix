{ config, pkgs, lib, ... }:

with pkgs;
let
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  dracula-pro = {
    foreground = "#F8F8F2";

    background-lighter = "#393649";
    background-light = "#2E2B3B";
    background = "#22212C";
    background-dark = "#17161D";
    background-darker = "#0B0B0F";

    comment = "#7970A9";
    selection = "#454158";
    subtle = "#424450";

    cyan = "#80FFEA";
    green = "#8AFF80";
    orange = "#FFCA80";
    pink = "#FF80BF";
    purple = "#9580FF";
    red = "#FF9580";
    yellow = "#FFFF80";

    ansi = {
      black_0 = "#454158";
      red_1 = "#FF9580";
      green_2 = "#8AFF80";
      yellow_3 = "#FFFF80";
      blue_4 = "#9580FF";
      purple_5 = "#FF80BF";
      cyan_6 = "#80FFEA";
      white_7 = "#F8F8F2";

      bright = {
        black_8 = "#7970A9";
        red_9 = "#FFAA99";
        green_10 = "#A2FF99";
        yellow_11 = "#FFFF99";
        blue_12 = "#AA99FF";
        purple_13 = "#FF99CC";
        cyan_14 = "#99FFEE";
        white_15 = "#FFFFFF";
      };
    };
  };
in {
  imports = [ (import "${home-manager}/nixos") ];

  home-manager.users.haoxiangliew = {
    xdg = {
      configFile = {
        "kitty/kitty.conf".text = ''
          # font size
          font_size             10.5

          # layouts
          enabled_layouts      Grid,Fat,Horizontal,Splits,Stack,Tall,Vertical

          # scrollback pager size
          scrollback_pager_history_size    800000

          # performance
          repaint_delay         0
          input_delay           0
          sync_to_monitor       no

          # window margins
          window_margin_width    10
          wayland_titlebar_color ${dracula-pro.background-light}

          # disable audio bell
          enable_audio_bell     no

          # Dracula Pro
          foreground            ${dracula-pro.foreground}
          background            ${dracula-pro.background}
          selection_foreground  ${dracula-pro.ansi.bright.white_15}
          selection_background  ${dracula-pro.selection}

          url_color ${dracula-pro.cyan}

          # black
          color0  ${dracula-pro.ansi.black_0}
          color8  ${dracula-pro.ansi.bright.black_8}

          # red
          color1  ${dracula-pro.ansi.red_1}
          color9  ${dracula-pro.ansi.bright.red_9}

          # green
          color2  ${dracula-pro.ansi.green_2}
          color10 ${dracula-pro.ansi.bright.green_10}

          # yellow
          color3  ${dracula-pro.ansi.yellow_3}
          color11 ${dracula-pro.ansi.bright.yellow_11}

          # blue
          color4  ${dracula-pro.ansi.blue_4}
          color12 ${dracula-pro.ansi.bright.blue_12}

          # magenta
          color5  ${dracula-pro.ansi.purple_5}
          color13 ${dracula-pro.ansi.bright.purple_13}

          # cyan
          color6  ${dracula-pro.ansi.cyan_6}
          color14 ${dracula-pro.ansi.bright.cyan_14}

          # white
          color7  ${dracula-pro.ansi.white_7}
          color15 ${dracula-pro.ansi.bright.white_15}

          # Cursor colors
          cursor            ${dracula-pro.foreground}
          cursor_text_color background

          # Tab bar colors
          active_tab_foreground   ${dracula-pro.background}
          active_tab_background   ${dracula-pro.foreground}
          inactive_tab_foreground ${dracula-pro.background}
          inactive_tab_background ${dracula-pro.comment}

          # Marks
          mark1_foreground ${dracula-pro.background}
          mark1_background ${dracula-pro.red}

          # Splits/Windows
          active_border_color ${dracula-pro.foreground}
          inactive_border_color ${dracula-pro.comment}
        '';
      };
    };
  };

}
