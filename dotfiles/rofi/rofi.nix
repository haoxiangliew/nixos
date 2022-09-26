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
        "rofi/config.rasi".text = ''
          configuration {
              modi: "drun,run,window";
              fixed-num-lines: true;
              show-icons: true;
              icon-theme: "Papirus-Dark";
              disable-history: true;
              case-sensitive: false;
              cycle: false;
              font: "Monospace 10.5";
          }

          * {
              /* Dracula theme colour palette */
              drac-bgd: ${dracula-pro.background};
              drac-cur: ${dracula-pro.selection};
              drac-fgd: ${dracula-pro.foreground};
              drac-cmt: ${dracula-pro.comment};
              drac-cya: ${dracula-pro.cyan};
              drac-grn: ${dracula-pro.green};
              drac-ora: ${dracula-pro.orange};
              drac-pnk: ${dracula-pro.pink};
              drac-pur: ${dracula-pro.purple};
              drac-red: ${dracula-pro.red};
              drac-yel: ${dracula-pro.yellow};
              foreground: @drac-fgd;
              background: @drac-bgd;
              active-background: @drac-pur;
              urgent-background: @drac-red;
              selected-background: @active-background;
              selected-urgent-background: @urgent-background;
              selected-active-background: @active-background;
              separatorcolor: @active-background;
              bordercolor: @drac-cur;
          }
          #window {
              background-color: @background;
              border:           1;
              border-radius:    10;
              border-color:     @bordercolor;
              padding:          5;
          }
          #mainbox {
              border:  0;
              padding: 5;
          }
          #message {
              border:       1px dash 0px 0px;
              border-color: @separatorcolor;
              padding:      1px;
          }
          #textbox {
              text-color: @foreground;
          }
          #listview {
              fixed-height: 0;
              border:       2px dash 0px 0px;
              border-color: @bordercolor;
              spacing:      2px;
              scrollbar:    false;
              padding:      2px 0px 0px;
          }
          #element {
              border:  0;
              padding: 1px;
          }
          #element.normal.normal {
              background-color: @background;
              text-color:       @foreground;
          }
          #element.normal.urgent {
              background-color: @urgent-background;
              text-color:       @background;
          }
          #element.normal.active {
              background-color: @active-background;
              text-color:       @background;
          }
          #element.selected.normal {
              background-color: @selected-background;
              text-color:       @background;
          }
          #element.selected.urgent {
              background-color: @selected-urgent-background;
              text-color:       @background;
          }
          #element.selected.active {
              background-color: @selected-active-background;
              text-color:       @background;
          }
          #element.alternate.normal {
              background-color: @background;
              text-color:       @foreground;
          }
          #element.alternate.urgent {
              background-color: @urgent-background;
              text-color:       @background;
          }
          #element.alternate.active {
              background-color: @active-background;
              text-color:       @background;
          }
          #scrollbar {
              width:        2px;
              border:       0;
              handle-width: 8px;
              padding:      0;
          }
          #sidebar {
              border:       2px dash 0px 0px;
              border-color: @separatorcolor;
          }
          #button.selected {
              background-color: @selected-background;
              text-color:       @foreground;
          }
          #inputbar {
              spacing:    0;
              text-color: @foreground;
              padding:    1px;
          }
          #case-indicator {
              spacing:    0;
              text-color: @foreground;
          }
          #entry {
              spacing:    0;
              text-color: @drac-cya;
          }
          #prompt {
              spacing:    0;
              text-color: @drac-grn;
          }
          #inputbar {
              children: [ prompt,textbox-prompt-colon,entry,case-indicator ];
          }
          #textbox-prompt-colon {
              expand:     false;
              str:        ":";
              margin:     0px 0.3em 0em 0em;
              text-color: @drac-grn;
          }

        '';
      };
    };
  };

}
