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
        "polybar/config".text = ''
          [settings]
          screenchange-reload = true

          [colors]
          background = ${dracula-pro.background}
          background-alt = ${dracula-pro.background-light}
          current-line = ${dracula-pro.selection}
          foreground = ${dracula-pro.foreground}
          comment = ${dracula-pro.comment}
          cyan = ${dracula-pro.cyan}
          green = ${dracula-pro.green}
          orange = ${dracula-pro.orange}
          pink = ${dracula-pro.pink}
          purple = ${dracula-pro.purple}
          red = ${dracula-pro.red}
          yellow = ${dracula-pro.yellow}

          [bar/main]
          monitor = ''${env:MONITOR:}

          width = 99%
          height = 30
          offset-x = 10
          offset-y = 10
          radius = 10

          override-redirect = true
          wm-restack = i3
          scroll-up = "#i3.prev"
          scroll-down = "#i3.next"

          padding-left = 1
          padding-right = 2
          module-margin-left = 2
          module-margin-right = 1

          font-0 = "Monospace:size=10.5;3"
          font-1 = "FontAwesome:size=10;3"
          font-2 = "Noto Color Emoji:size=10:scale=10;3"
          font-3 = "Source Han Sans:size=10;1"

          background = ''${colors.background}
          foreground = ''${colors.foreground}

          modules-left = i3 xwindow playerctl
          # modules-center = xwindow
          modules-right = battery date time caffeine

          enable-ipc = true

          tray-position = center

          [bar/secondary]
          monitor = ''${env:MONITOR:}

          width = 99%
          height = 30
          offset-x = 10
          offset-y = 10
          radius = 10

          override-redirect = true
          wm-restack = i3
          scroll-up = "#i3.prev"
          scroll-down = "#i3.next"

          padding-left = 1
          padding-right = 2
          module-margin-left = 2
          module-margin-right = 1

          font-0 = "Monospace:size=10.5;3"
          font-1 = "FontAwesome:size=10;3"
          font-2 = "Noto Color Emoji:size=10:scale=10;3"
          font-3 = "Source Han Sans:size=10;1"

          background = ''${colors.background}
          foreground = ''${colors.foreground}

          modules-left = i3 xwindow
          # modules-center = xwindow
          modules-right = battery date time

          enable-ipc = true

          [bar/vertical]
          monitor = ''${env:MONITOR:}

          width = 98%
          height = 30
          offset-x = 10
          offset-y = 10
          radius = 10

          override-redirect = true
          wm-restack = i3
          scroll-up = "#i3.prev"
          scroll-down = "#i3.next"

          padding-left = 1
          padding-right = 2
          module-margin-left = 2
          module-margin-right = 1

          font-0 = "Monospace:size=10.5;3"
          font-1 = "FontAwesome:size=10;3"
          font-2 = "Noto Color Emoji:size=10:scale=10;3"
          font-3 = "Source Han Sans:size=10;1"

          background = ''${colors.background}
          foreground = ''${colors.foreground}

          modules-left = i3 xwindow
          # modules-center = xwindow
          modules-right = battery date time

          enable-ipc = true

          [module/i3]
          type = internal/i3
          pin-workspaces = true
          wrapping-scroll = false

          label-focused-foreground = ''${colors.purple}
          label-unfocused-foreground = ''${colors.comment}
          label-urgent-foreground = ''${colors.red}

          [module/xwindow]
          type = internal/xwindow
          format = <label>
          label = %title:0:25:...%

          [module/battery]
          type = internal/battery
          battery = BAT0
          adapter = AC
          time-format = %H:%M
          label-charging = %percentage%% - %time%
          label-discharging = %percentage%% - %time%
          label-low = %percentage%% - %time%
          format-charging = <animation-charging> <label-charging>
          format-discharging = <ramp-capacity> <label-discharging>
          format-full = <ramp-capacity> <label-full>
          format-low = <ramp-capacity> <animation-low> <label-low>

          animation-charging-0 = 
          animation-charging-1 = 
          animation-charging-2 = 
          animation-charging-3 = 
          animation-charging-4 = 
          animation-charging-framerate = 750
          ramp-capacity-0 = 
          ramp-capacity-1 = 
          ramp-capacity-2 = 
          ramp-capacity-3 = 
          ramp-capacity-4 = 
          animation-low-0 = 
          animation-low-1 = 
          animation-low-framerate = 200

          [module/date]
          type = internal/date
          interval = 1
          date = %a, %b %e %Y
          format =  <label>
          label = %date%

          [module/time]
          type = internal/date
          interval = 1
          time = %H:%M:%S
          time-alt = %I:%M:%S %p
          format =  <label>
          label = %time%

          [module/playerctl]
          type = custom/script
          tail = true
          interval = 1
          format =  <label>
          label = %output:0:25:...%
          exec = playerctl metadata --format "{{ title }} - {{ artist }}"
          click-left = playerctl play-pause
          double-click-left = playerctl next
          click-right = playerctl previous

          [module/caffeine]
          type = custom/ipc
          hook-0 = echo ''
          hook-1 = echo ''
          click-left = ~/.config/polybar/caffeine.sh
          initial = 1
        '';
      };
    };
  };

}
