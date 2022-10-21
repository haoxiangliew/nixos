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
        "i3/config".text = ''
          # haoxiangliew's i3 configuration

          ### essentials

          # set mod to super
          set $mod Mod4

          # mod + mouse to float
          floating_modifier $mod

          # exec with --no-startup-id
          set $exec exec --no-startup-id

          ### startup
          exec_always --no-startup-id "autorandr --change && feh --bg-fill ~/haoxiangliew/Wallpapers/lycoris-recoil-2.png"
          exec_always --no-startup-id "~/.config/i3/tablet.sh"

          $exec "exec /run/current-system/sw/libexec/polkit-gnome-authentication-agent-1"
          $exec "light-locker"
          $exec "numlockx"
          $exec "picom -b --experimental-backends"
          # $exec "pulseeffects --gapplication-service"
          $exec "easyeffects --gapplication-service"
          $exec "kitty emacs --daemon"
          $exec "flameshot"
          $exec "ibus-daemon -dr"
          $exec "nm-applet"
          $exec "blueman-applet"
          $exec "solaar -w hide"
          $exec "udiskie -t"

          ### appearance


          # font
          font pango:monospace 9

          # dracula theme
          # class                 border  bground text    indicator child_border
          client.focused          ${dracula-pro.comment} ${dracula-pro.comment} ${dracula-pro.foreground} ${dracula-pro.comment} ${dracula-pro.comment}
          client.focused_inactive ${dracula-pro.selection} ${dracula-pro.selection} ${dracula-pro.foreground} ${dracula-pro.selection} ${dracula-pro.selection}
          client.unfocused        ${dracula-pro.background} ${dracula-pro.background} ${dracula-pro.foreground} ${dracula-pro.background} ${dracula-pro.background}
          client.urgent           ${dracula-pro.selection} ${dracula-pro.red} ${dracula-pro.foreground} ${dracula-pro.red} ${dracula-pro.red}
          client.placeholder      ${dracula-pro.background} ${dracula-pro.background} ${dracula-pro.foreground} ${dracula-pro.background} ${dracula-pro.background}

          client.background       ${dracula-pro.foreground}

          # polybar
          gaps top 40
          exec_always --no-startup-id sleep 1 && ~/.config/polybar/polybar.sh

          # smart borders no titlebars
          for_window [class=".*"] border pixel 0
          # smart_borders on

          # prevent titlebars from being obstructed by rounded corners
          for_window [class=".*"] title_format "  %title"

          # gaps
          gaps inner 10

          ### keybinds

          # terminal
          bindsym $mod+Return $exec kitty
          bindsym $mod+Shift+Return $exec "emacsclient -c --eval '(vterm)'"

          # kill
          bindsym $mod+Shift+q kill

          # rofi
          bindsym $mod+d $exec "rofi -show drun"
          bindsym $mod+Shift+d $exec "rofi -show run"
          bindsym $mod+Tab $exec "rofi -show window"
          bindsym $mod+Shift+x $exec "rofi -show p -modi p:\\"rofi-power-menu --no-symbols --choices=shutdown/reboot/suspend/logout/lockscreen\\""

          # emacs
          bindsym $mod+z $exec "emacsclient -c"
          bindsym $mod+Shift+z $exec "emacs"
          bindsym $mod+x $exec "kitty emacs --daemon"

          # vscode
          bindsym $mod+c $exec "code --ignore-gpu-blacklist --enable-gpu-rasterization --enable-native-gpu-memory-buffers"

          # chrome
          bindsym $mod+b $exec "google-chrome-unstable"
          bindsym $mod+n $exec "google-chrome-unstable --incognito"

          # firefox
          # bindsym $mod+b $exec "firefox"
          # bindsym $mod+n $exec "firefox --private-window"


          # flameshot
          bindsym $mod+y $exec "flameshot gui"
          bindsym $mod+Shift+y $exec "flameshot screen -c"

          # lock
          bindsym $mod+Escape $exec "xautolock -locknow"

          # volume control
          bindsym XF86AudioRaiseVolume $exec "amixer -q sset Master 2%+ && notify-send --hint=string:x-dunst-stack-tag:volume \\"Volume: $(amixer get Master | grep '\[*\]' | head -1 | awk '{print $5 $6}')\\""
          bindsym XF86AudioLowerVolume $exec "amixer -q set Master 2%- && notify-send --hint=string:x-dunst-stack-tag:volume \\"Volume: $(amixer get Master | grep  '\[*\]' | head -1 | awk '{print $5 $6}')\\""
          bindsym XF86AudioMute        $exec "amixer set Master toggle && notify-send --hint=string:x-dunst-stack-tag:volume \\"Volume: $(amixer get Master | grep '\[*\]' | head -1 | awk '{print $5 $6}')\\""
          bindsym XF86AudioMicMute     $exec "amixer set Capture toggle && notify-send --hint=string:x-dunst-stack-tag:volume \\"Mic: $(amixer get Capture | grep '\[*\]' | head -1 | awk '{print $5 $6}')\\""

          # brightness control
          bindsym XF86MonBrightnessUp   $exec "xbacklight -inc 5 && notify-send --hint=string:x-dunst-stack-tag:volume \\"Brightness: $(printf '%.0f' $(xbacklight -get))%\\""
          bindsym XF86MonBrightnessDown $exec "xbacklight -dec 5 && notify-send --hint=string:x-dunst-stack-tag:volume \\"Brightness: $(printf '%.0f' $(xbacklight -get))%\\""
          bindsym XF86Display           $exec "arandr"

          # zen mode
          bindsym $mod+q mode "zen"; $exec "polybar-msg cmd hide && i3-msg \"gaps top all set 0\""

          mode "zen" {
              bindsym $mod+q mode "default"; $exec "polybar-msg cmd show && i3-msg \"gaps top all set 40\""
          }

          ### default keybinds

          # focus
          bindsym $mod+h focus left
          bindsym $mod+j focus down
          bindsym $mod+k focus up
          bindsym $mod+l focus right

          bindsym $mod+Left focus left
          bindsym $mod+Down focus down
          bindsym $mod+Up focus up
          bindsym $mod+Right focus right

          # move focus
          bindsym $mod+Shift+h move left
          bindsym $mod+Shift+j move down
          bindsym $mod+Shift+k move up
          bindsym $mod+Shift+l move right

          bindsym $mod+Shift+Left move left
          bindsym $mod+Shift+Down move down
          bindsym $mod+Shift+Up move up
          bindsym $mod+Shift+Right move right

          # move focused workspace between outputs
          bindsym $mod+Ctrl+h move workspace to output left
          bindsym $mod+Ctrl+j move workspace to output down
          bindsym $mod+Ctrl+k move workspace to output up
          bindsym $mod+Ctrl+l move workspace to output right

          bindsym $mod+Ctrl+Left move workspace to output left
          bindsym $mod+Ctrl+Down move workspace to output down
          bindsym $mod+Ctrl+Up move workspace to output up
          bindsym $mod+Ctrl+Right move workspace to output right

          # horizontal split
          bindsym $mod+Shift+v split h

          # vertical split
          bindsym $mod+v split v

          # fullscreen
          bindsym $mod+f fullscreen toggle

          # change container
          bindsym $mod+s layout stacking
          bindsym $mod+w layout tabbed
          bindsym $mod+e layout toggle split

          # toggle tiling / floating
          bindsym $mod+Shift+space floating toggle

          # focus between tiling / floating windows
          bindsym $mod+space focus mode_toggle

          # focus parent
          bindsym $mod+a focus parent

          # workspaces
          set $ws1 "1"
          set $ws2 "2"
          set $ws3 "3"
          set $ws4 "4"
          set $ws5 "5"
          set $ws6 "6"
          set $ws7 "7"
          set $ws8 "8"
          set $ws9 "9"
          set $ws10 "10"

          # switch to workspace
          bindsym $mod+1 workspace number $ws1
          bindsym $mod+2 workspace number $ws2
          bindsym $mod+3 workspace number $ws3
          bindsym $mod+4 workspace number $ws4
          bindsym $mod+5 workspace number $ws5
          bindsym $mod+6 workspace number $ws6
          bindsym $mod+7 workspace number $ws7
          bindsym $mod+8 workspace number $ws8
          bindsym $mod+9 workspace number $ws9
          bindsym $mod+0 workspace number $ws10

          # move focused container to workspace
          bindsym $mod+Shift+1 move container to workspace number $ws1
          bindsym $mod+Shift+2 move container to workspace number $ws2
          bindsym $mod+Shift+3 move container to workspace number $ws3
          bindsym $mod+Shift+4 move container to workspace number $ws4
          bindsym $mod+Shift+5 move container to workspace number $ws5
          bindsym $mod+Shift+6 move container to workspace number $ws6
          bindsym $mod+Shift+7 move container to workspace number $ws7
          bindsym $mod+Shift+8 move container to workspace number $ws8
          bindsym $mod+Shift+9 move container to workspace number $ws9
          bindsym $mod+Shift+0 move container to workspace number $ws10

          # reload the configuration file
          bindsym $mod+Shift+c reload
          # restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
          bindsym $mod+Shift+r restart
          # exit i3 (logs you out of your X session)
          bindsym $mod+Shift+e $exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"

          # resize mode
          bindsym $mod+r mode "resize"

          mode "resize" {
              bindsym h resize shrink width 10 px or 10 ppt
              bindsym j resize grow height 10 px or 10 ppt
              bindsym k resize shrink height 10 px or 10 ppt
              bindsym l resize grow width 10 px or 10 ppt

              bindsym Left resize shrink width 10 px or 10 ppt
              bindsym Down resize grow height 10 px or 10 ppt
              bindsym Up resize shrink height 10 px or 10 ppt
              bindsym Right resize grow width 10 px or 10 ppt

              bindsym Return mode "default"
              bindsym Escape mode "default"
              bindsym $mod+r mode "default"
          }
        '';
      };
    };
  };

}
