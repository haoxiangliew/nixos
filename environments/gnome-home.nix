{ config, pkgs, lib, ... }:

with pkgs;
let

  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  dracula-qt = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/dracula/qt5/master/Dracula.conf";
    sha256 = "06bhak8ix01gpa2p43bf3hzw74375zgdhbjjzr8qj91qddycpvdb";
  };
  catppuccin-gtk-mocha = pkgs.catppuccin-gtk.override {
    accents = [ "mauve" ];
    variant = "mocha";
  };

in {
  imports = [ (import "${home-manager}/nixos") ];

  home-manager.users.haoxiangliew = {
    home.activation = {
      gtk4Assets = ''
        rm -rf ~/.config/gtk-4.0/assets
        rm -rf ~/.config/gtk-4.0/gtk.css
        rm -rf ~/.config/gtk-4.0/gtk-dark.css
        ln -sf ${catppuccin-gtk-mocha}/share/themes/Catppuccin-Mocha-Standard-Mauve-dark/gtk-4.0/assets ~/.config/gtk-4.0/assets
        ln -sf ${catppuccin-gtk-mocha}/share/themes/Catppuccin-Mocha-Standard-Mauve-dark/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk.css
        ln -sf ${catppuccin-gtk-mocha}/share/themes/Catppuccin-Mocha-Standard-Mauve-dark/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/gtk-dark.css
      '';
    };
    xdg = {
      configFile = {
        "keyboard-toggle.sh".source = ../dotfiles/keyboard-toggle.sh;
        "mount.sh".source = ../dotfiles/mount.sh;
        "umount.sh".source = ../dotfiles/umount.sh;
        "kitty/kitty.conf".source = ../dotfiles/kitty/kitty.conf;
        # "wezterm/wezterm.lua".source = ../dotfiles/wezterm/wezterm.lua;
        # "wezterm/.stylua.toml".source = ../dotfiles/wezterm/.stylua.toml;
        "fish/themes/catppuccin-mocha.theme".source =
          ../dotfiles/fish/catppuccin-mocha.theme;
        # "qt5ct/colors/Dracula.conf".source = "${dracula-qt}";
        "autostart/armcord.desktop".text = ''
          [Desktop Entry]
          Name=ArmCord
          Comment=ArmCord is a custom client designed to enhance your Discord experience while keeping everything lightweight.
          Exec=armcord --disable-gpu
          Icon=armcord
          Terminal=false
          Type=Application
          Categories=Network
        '';
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
        "autostart/mullvad-vpn.desktop".text = ''
          [Desktop Entry]
          Name=Mullvad VPN
          Exec=mullvad-vpn
          Terminal=false
          Type=Application
          Icon=mullvad-vpn
          StartupWMClass=Mullvad VPN
          Comment=Mullvad VPN client
          Categories=Network;
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
          Exec=kitty -e emacs --daemon
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
