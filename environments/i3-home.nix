{ config, pkgs, lib, ... }:

with pkgs;
let

  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/master.tar.gz";

in {
  imports = [
    (import "${home-manager}/nixos")
    ../dotfiles/dunst/dunstrc.nix
    ../dotfiles/flameshot/flameshot.nix
    ../dotfiles/kitty/kitty.nix
    ../dotfiles/rofi/rofi.nix
    ../dotfiles/i3/i3-config.nix
    ../dotfiles/polybar/polybar-config.nix
  ];

  home-manager.users.haoxiangliew = {
    xdg = {
      configFile = {
        # "dunst/dunstrc".source = ../dotfiles/dunst/dunstrc;
        # "flameshot/flameshot.ini".source = ../dotfiles/flameshot/flameshot.ini;
        # "kitty/kitty.conf".source = ./dotfiles/kitty/kitty.conf;
        "picom/picom.conf".source = ../dotfiles/picom/picom.conf;
        # "rofi/config.rasi".source = ../dotfiles/rofi/config.rasi;
        # "i3/config".source = ../dotfiles/i3/config;
        "i3/tablet.sh".source = ../dotfiles/i3/tablet.sh;
        # "polybar/config".source = ../dotfiles/polybar/config;
        "polybar/keyboard-toggle.sh".source =
          ../dotfiles/polybar/keyboard-toggle.sh;
        "polybar/caffeine.sh".source = ../dotfiles/polybar/caffeine.sh;
        "polybar/polybar.sh".source = ../dotfiles/polybar/polybar.sh;
      };
    };
  };
}
