{ config, pkgs, lib, ... }:

with pkgs;
let

  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/master.tar.gz";

in {
  imports = [ (import "${home-manager}/nixos") ];

  home-manager.users.haoxiangliew = {
    xdg = {
      configFile = {
        "dunst/dunstrc".source = ../dotfiles/dunst/dunstrc;
        "flameshot/flameshot.ini".source = ../dotfiles/flameshot/flameshot.ini;
        "picom/picom.conf".source = ../dotfiles/picom/picom.conf;
        "rofi/config.rasi".source = ../dotfiles/rofi/config.rasi;
        "i3/config".source = ../dotfiles/i3/config;
        "i3/tablet.sh".source = ../dotfiles/i3/tablet.sh;
        "polybar/config".source = ../dotfiles/polybar/config;
        "polybar/caffeine.sh".source = ../dotfiles/polybar/caffeine.sh;
        "polybar/polybar.sh".source = ../dotfiles/polybar/polybar.sh;
      };
    };
  };
}
