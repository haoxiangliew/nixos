{ config, pkgs, lib, ... }:

{
  environment = {
    variables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
    };
    systemPackages = (with pkgs; [
      easyeffects
      evtest
      glib
      gnome-obfuscate
      helvum
      kitty
      libinput
      libsForQt5.qt5.qtwayland
      pinentry-gnome
      qt6.qtwayland
    ]) ++ (with pkgs.gnome; [
      adwaita-icon-theme
      dconf-editor
      gnome-tweaks
      gnome-power-manager
    ]) ++ (with pkgs.gnomeExtensions; [ appindicator alphabetical-app-grid espresso ]);
    gnome = {
      excludePackages = (with pkgs; [ gnome-photos gnome-tour ])
        ++ (with pkgs.gnome; [
          # cheese # webcam tool
          gnome-music
          gnome-terminal
          gedit # text editor
          epiphany # web browser
          geary # email reader
          evince # document viewer
          gnome-characters
          totem # video player
          tali # poker game
          iagno # go game
          hitori # sudoku game
          atomix # puzzle game
        ]);
    };
    etc = {
      "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text =
        "	bluez_monitor.properties = {\n		[\"bluez5.enable-sbc-xq\"] = true,\n		[\"bluez5.enable-msbc\"] = true,\n		[\"bluez5.enable-hw-volume\"] = true,\n		[\"bluez5.headset-roles\"] = \"[ hsp_hs hsp_ag hfp_hf hfp_ag ]\"\n	}\n";
    };
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  qt5.platformTheme = "qt5ct";

  sound.enable = false;

  hardware.pulseaudio.enable = false;

  services = {
    xserver = {
      enable = true;
      displayManager = {
        # defaultSession = "gnome-xorg";
        defaultSession = "gnome";
        gdm = {
          enable = true;
          wayland = true;
        };
      };
      desktopManager.gnome.enable = true;
    };
    dbus = {
      enable = true;
      packages = with pkgs; [ dconf gcr ];
    };
    gnome.gnome-browser-connector.enable = true;
    pipewire = {
      enable = true;
      wireplumber.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
    udev.packages = with pkgs.gnome; [ gnome-settings-daemon ];
  };
}
