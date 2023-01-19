{ config, pkgs, lib, ... }:

with pkgs;
let

  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  dracula-qt = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/dracula/qt5/master/Dracula.conf";
    sha256 = "06bhak8ix01gpa2p43bf3hzw74375zgdhbjjzr8qj91qddycpvdb";
  };

in {
  imports = [ (import "${home-manager}/nixos") ];

  home-manager.users.haoxiangliew = {
    home.activation = {
      gtk4Assets = ''
        if [[ ! -h ~/.config/gtk-4.0/assets ]]; then
          ln -s /etc/nixos/dotfiles/gtk-4.0/assets ~/.config/gtk-4.0/assets
        fi
      '';
    };
    xdg = {
      configFile = {
        "keyboard-toggle.sh".source = ../dotfiles/polybar/keyboard-toggle.sh;
        "kitty/kitty.conf".source = ../dotfiles/kitty/kitty.conf;
        # "qt5ct/colors/Dracula.conf".source = "${dracula-qt}";
        "gtk-4.0/gtk.css".source = ../dotfiles/gtk-4.0/gtk.css;
        "gtk-4.0/gtk-dark.css".source = ../dotfiles/gtk-4.0/gtk-dark.css;
        # "autostart/armcord.desktop".text = ''
        #   [Desktop Entry]
        #   Name=ArmCord
        #   Comment=ArmCord is a custom client designed to enhance your Discord experience while keeping everything lightweight.
        #   Exec=armcord
        #   Icon=armcord
        #   Terminal=false
        #   Type=Application
        #   Categories=Network
        # '';
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
        # "autostart/galaxy-buds-client.desktop".text = ''
        #   [Desktop Entry]
        #   Name=GalaxyBudsClient
        #   Comment=Unofficial Galaxy Buds Manager for Windows and Linux
        #   Exec=GalaxyBudsClient
        #   Icon=GalaxyBudsClient
        #   GenericName=Galaxy Buds Client
        #   StartupNotify=false
        #   Terminal=false
        #   Type=Application
        #   Categories=Settings
        # '';
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
