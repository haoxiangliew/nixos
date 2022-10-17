{ config, pkgs, lib, ... }:

with pkgs;
let

  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/master.tar.gz";

in {
  imports = [ (import "${home-manager}/nixos") ../dotfiles/kitty/kitty.nix ];

  home-manager.users.haoxiangliew = {
    xdg = {
      configFile = {
        "autostart/easyeffects-service.desktop".text = ''
          [Desktop Entry]
          Name=EasyEffects
          Comment=EasyEffects Service
          Exec=easyeffects --gapplication-service
          Icon=easyeffects
          StartupNotify=false
          Terminal=false
          Type=Application
        '';
        "autostart/plex-mpv-shim.desktop".text = ''
          [Desktop Entry]
          Name=plex-mpv-shim
          Comment=Plex MPV Shim Service
          Exec=plex-mpv-shim
          Icon=plex
          StartupNotify=false
          Terminal=false
          Type=Application
        '';
        "autostart/solaar.desktop".text = ''
          [Desktop Entry]
          Name=Solaar
          Comment=Logitech Unifying Receiver peripherals manager
          Exec=solaar --window=hide
          Icon=solaar
          StartupNotify=true
          Terminal=false
          Type=Application
          Keywords=logitech;unifying;receiver;mouse;keyboard;
          Categories=Utility;GTK;
        '';
        "autostart/emacs-daemon.desktop".text = ''
          [Desktop Entry]
          Name=Emacs (Daemon)
          Comment=Start the Emacs Daemon
          Exec=kitty emacs --daemon
          Icon=emacs
          StartupNotify=true
          Terminal=false
          Type=Application
          Categories=Development;TextEditor;
        '';
      };
    };
  };
}
