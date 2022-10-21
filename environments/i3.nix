{ config, pkgs, lib, ... }:

{
  nixpkgs = {
    overlays = let
      picomOverlay = (self: super: {
        picom = super.picom.overrideAttrs (_: {
          src = builtins.fetchTarball
            "https://github.com/dccsillag/picom/archive/implement-window-animations.tar.gz";
        });
      });
      pulseeffectsOverlay = (self: super: {
        pulseeffects-legacy = super.pulseeffects-legacy.overrideAttrs (_: {
          src = builtins.fetchTarball
            "https://github.com/wwmm/pulseeffects/archive/pulseaudio-legacy.tar.gz";
        });
      });
    in [ picomOverlay pulseeffectsOverlay ];
  };

  environment = {
    systemPackages = with pkgs; [
      pinentry-gtk2
      xdragon
      xorg.xdpyinfo
      xorg.xmodmap
      xorg.xwininfo
      xclip
    ];
    etc = {
      "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text =
        "	bluez_monitor.properties = {\n		[\"bluez5.enable-sbc-xq\"] = true,\n		[\"bluez5.enable-msbc\"] = true,\n		[\"bluez5.enable-hw-volume\"] = true,\n		[\"bluez5.headset-roles\"] = \"[ hsp_hs hsp_ag hfp_hf hfp_ag ]\"\n	}\n";
    };
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "gtk2";
    };
  };

  qt5 = {
    enable = true;
    platformTheme = "gtk";
    style = "adwaita-dark";
  };

  # sound.enable = true;
  sound.enable = false;

  hardware = {
    pulseaudio.enable = false;
    # pulseaudio = {
    #   enable = true;
    #   support32Bit = true;
    #   package = pkgs.pulseaudioFull;
    #   daemon.config = {
    #     default-fragments = 2;
    #     default-fragment-size-msec = 5;
    #   };
    # };
    acpilight.enable = true;
  };

  services = {
    xserver = {
      enable = true;
      windowManager = {
        i3 = {
          enable = true;
          package = pkgs.i3-gaps;
          extraPackages = with pkgs; [
            arandr
            autorandr
            dunst
            flameshot
            kitty
            libnotify
            lightlocker
            networkmanagerapplet
            numlockx
            pavucontrol
            picom
            playerctl
            polkit_gnome
            polybarFull
            # pulseeffects-legacy
            easyeffects
            rofi
            rofi-power-menu
            udiskie
          ];
        };
      };
      displayManager = {
        defaultSession = "none+i3";
        lightdm = {
          enable = true;
          background = pkgs.nixos-artwork.wallpapers.dracula.gnomeFilePath;
          greeters.gtk = {
            enable = true;
            clock-format = "%H:%M:%S";
            theme = {
              name = "Dracula";
              package = pkgs.dracula-theme;
            };
            iconTheme = {
              name = "Papirus-Dark";
              package = pkgs.papirus-icon-theme;
            };
            cursorTheme = {
              name = "Capitaine Cursors";
              package = pkgs.capitaine-cursors;
              size = 8;
            };
            extraConfig = ''
              position=200,start 50%,center
              greeter-hide-users=false
            '';
          };
        };
      };
      desktopManager.xterm.enable = false;
      xautolock = {
        enable = true;
        killtime = 20;
        killer = "/run/current-system/systemd/bin/systemctl suspend";
        time = 15;
        locker = "/run/current-system/sw/bin/loginctl lock-session";
        nowlocker = "/run/current-system/sw/bin/loginctl lock-session";
        enableNotifier = true;
        notify = 10;
        notifier =
          ''${pkgs.libnotify}/bin/notify-send "Locking in 10 seconds"'';
        extraOptions = [ "-detectsleep" ];
      };
    };
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
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
        CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
        USB_AUTOSUSPEND = 0;
        USB_BLACKLIST_BTUSB = 1;
        RESTORE_DEVICE_STATE_ON_STARTUP = 1;
      };
    };
    blueman.enable = true;
    geoclue2.enable = true;
    tzupdate.enable = true;
    udisks2.enable = true;
    unclutter-xfixes.enable = true;
  };

  systemd = {
    user.services = {
      mpris-proxy = {
        description = "Mpris Proxy";
        after = [ "network.target" "sound.target" ];
        serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
        wantedBy = [ "default.target" ];
      };
    };
  };

  xdg = { portal = { extraPortals = with pkgs; [ xdg-desktop-portal-gtk ]; }; };
}
