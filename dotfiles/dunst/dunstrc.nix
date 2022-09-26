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
        "dunst/dunstrc".text = ''
          [global]
              monitor = 0
              follow = mouse
              width = 300
              height = 300
              origin = top-right
              offset = 25x65
              scale = 0
              notification_limit = 0
              progress_bar = true
              progress_bar_height = 10
              progress_bar_frame_width = 1
              progress_bar_min_width = 150
              progress_bar_max_width = 300
              indicate_hidden = yes
              transparency = 15
              separator_height = 1
              padding = 8
              horizontal_padding = 10
              text_icon_padding = 0
              frame_width = 0
              frame_color = "${dracula-pro.background}"
              separator_color = frame
              sort = yes
              idle_threshold = 120
              font = Monospace 10.5
              line_height = 0
              markup = full
              format = "%s %p\n%b"
              alignment = left
              vertical_alignment = center
              show_age_threshold = 60
              ellipsize = middle
              ignore_newline = no
              stack_duplicates = true
              hide_duplicate_count = false
              show_indicators = yes
              icon_position = left
              min_icon_size = 0
              max_icon_size = 64
              icon_path = /usr/share/icons/gnome/16x16/status/:/usr/share/icons/gnome/16x16/devices/
              sticky_history = yes
              history_length = 20
              dmenu = /usr/bin/dmenu -p dunst:
              browser = /usr/bin/firefox -new-tab
              always_run_script = true
              title = Dunst
              class = Dunst
              corner_radius = 0
              ignore_dbusclose = false
              force_xwayland = false
              force_xinerama = false
              mouse_left_click = close_current
              mouse_middle_click = do_action, close_current
              mouse_right_click = close_all
          [experimental]
              per_monitor_dpi = false
          [urgency_low]
              background = "${dracula-pro.background}"
              foreground = "${dracula-pro.comment}"
              timeout = 10
          [urgency_normal]
              background = "${dracula-pro.background}"
              foreground = "${dracula-pro.purple}"
              timeout = 10
          [urgency_critical]
              background = "${dracula-pro.red}"
              foreground = "${dracula-pro.foreground}"
              frame_color = "${dracula-pro.red}"
              timeout = 0
        '';
      };
    };
  };

}
