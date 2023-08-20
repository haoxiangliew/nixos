{ config, pkgs, lib, ... }:

{
  xdg = {
    configFile = {
      "keyboard-toggle.sh".source = ../../config/keyboard-toggle.sh;
      "kitty/kitty.conf".source = ../../config/kitty/kitty.conf;
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
      # "autostart/plex-mpv-shim.desktop".text = ''
      #   [Desktop Entry]
      #   Name=plex-mpv-shim
      #   Comment=Plex MPV Shim Service
      #   Exec=plex-mpv-shim
      #   Icon=plex
      #   StartupNotify=false
      #   Terminal=false
      #   Type=Application
      # '';
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
}
