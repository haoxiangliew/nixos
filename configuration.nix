# Hao Xiang's nixos-unstable configuration

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./devices/e595.nix
    ./environments/i3.nix
    ./home.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "tcp_bbr" ];
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "btrfs" "ntfs" ];
    cleanTmpDir = true;
    kernel.sysctl = {
      # Disable sysreq
      "kernel.sysreq" = "0";
      # TCP Hardening
      "net.ipv4.icmp_ignore_bogus_error_responses" = "1";
      "net.ipv4.conf.default.rp_filter" = "1";
      "net.ipv4.conf.all.rp_filter" = "1";
      "net.ipv4.conf.all.accept_source_route" = "0";
      "net.ipv6.conf.all.accept_source_route" = "0";
      "net.ipv4.conf.all.send_redirects" = "0";
      "net.ipv4.conf.default.send_redirects" = "0";
      "net.ipv4.conf.all.accept_redirects" = "0";
      "net.ipv4.conf.default.accept_redirects" = "0";
      "net.ipv4.conf.all.secure_redirects" = "0";
      "net.ipv4.conf.default.secure_redirects" = "0";
      "net.ipv6.conf.all.accept_redirects" = "0";
      "net.ipv6.conf.default.accept_redirects" = "0";
      "net.ipv4.tcp_syncookies" = "1";
      "net.ipv4.tcp_rfc1337" = "1";
      # TCP Fast Open
      "net.ipv4.tcp_fastopen" = "3";
      "net.core.default_qdisc" = "cake";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
  };

  networking = {
    hostName = "nixos";
    dhcpcd.enable = false;
    networkmanager = {
      enable = true;
      ethernet.macAddress = "stable";
      wifi.macAddress = "stable";
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 43 443 22000 3000 ];
      allowedUDPPorts = [ 53 22000 21027 32410 32412 32413 32414 ];
      allowedTCPPortRanges = [{
        from = 1714;
        to = 1764;
      }];
      allowedUDPPortRanges = [{
        from = 1714;
        to = 1764;
      }];
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ rime ];
    };
  };

  console = {
    font = "Lat2-Terminus16";
    # keyMap = "us";
    useXkbConfig = true;
  };

  time = {
    timeZone = null;
    hardwareClockInLocalTime = true;
  };

  system = {
    stateVersion = config.system.nixos.release;
    activationScripts = {
      pkexecFix = {
        text = ''
          mkdir -m 0755 -p /bin
          ln -sf /run/current-system/sw/bin/bash /bin/.bash.tmp
          mv /bin/.bash.tmp /bin/bash
          ln -sf /run/wrappers/bin/pkexec /usr/bin/.pkexec.tmp
          mv /usr/bin/.pkexec.tmp /usr/bin/pkexec
        '';
        deps = [ ];
      };
    };
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" "haoxiangliew" ];
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      joypixels.acceptLicense = true;
      packageOverrides = pkgs: {
        nur = import (builtins.fetchTarball
          "https://github.com/nix-community/NUR/archive/master.tar.gz") {
            inherit pkgs;
          };
      };
    };
    overlays = let
      pulseeffectsOverlay = (self: super: {
        pulseeffects-legacy = super.pulseeffects-legacy.overrideAttrs (_: {
          src = builtins.fetchTarball
            "https://github.com/wwmm/pulseeffects/archive/pulseaudio-legacy.tar.gz";
        });
      });
      neovimOverlay = (import (builtins.fetchTarball {
        url =
          "https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz";
      }));
      pragmataProOverlay = (final: prev: {
        pragmataPro = prev.callPackage ./packages/pragmataPro { };
      });
    in [ pulseeffectsOverlay pragmataProOverlay ];
  };

  environment = {
    variables = { GTK_USE_PORTAL = "1"; };
    pathsToLink = [ "/libexec" ];
    systemPackages = with pkgs; [
      (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
      appimage-run
      aspell
      captive-browser
      efitools
      feh
      git
      htop
      hunspell
      hunspellDicts.en_US
      iftop
      libsForQt5.qtstyleplugin-kvantum
      libsecret
      lm_sensors
      mpv
      ncdu
      neofetch
      openssl
      p7zip
      parted
      piper
      psmisc
      ranger
      thefuck
      tree
      unrar
      unzip
      virt-manager
      virt-viewer
      wget
      xdg-utils
      nixfmt
      nodePackages.bash-language-server
      rnix-lsp
    ];
  };

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      cm_unicode
      corefonts
      dejavu_fonts
      font-awesome_4
      joypixels
      pragmataPro
      source-han-mono
      source-han-sans
      source-han-serif
      ubuntu_font_family
      vistafonts
    ];
    fontconfig = {
      enable = true;
      cache32Bit = true;
      useEmbeddedBitmaps = true;
      defaultFonts = {
        serif = [ "CMU Serif" "Source Han Serif" ];
        emoji = [ "JoyPixels" ];
        sansSerif = [ "Ubuntu" "Source Han Sans" ];
        monospace = [ "PragmataPro Mono Liga" "Source Han Mono" ];
      };
    };
  };

  programs = {
    fish = {
      enable = true;
      shellInit = builtins.readFile ./dotfiles/fish/config.fish;
    };
    gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        general = { renice = 10; };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          amd_performance_level = "high";
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };
    neovim = {
      enable = true;
      withRuby = true;
      withPython3 = true;
      withNodeJs = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
    adb.enable = true;
    dconf.enable = true;
    mtr.enable = true;
  };

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    opengl = {
      enable = true;
      setLdLibraryPath = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
    # opentabletdriver.enable = true;
    sensor.iio.enable = true;
  };

  services = {
    xserver = {
      libinput = {
        enable = true;
        touchpad = {
          accelProfile = "flat";
          disableWhileTyping = true;
          naturalScrolling = true;
        };
        mouse = { accelProfile = "flat"; };
      };
      wacom.enable = true;
      config = ''
        Section "InputClass"
          Identifier "mouse accel"
          Driver "libinput"
          MatchIsPointer "on"
          Option "AccelProfile" "flat"
          Option "AccelSpeed" "0"
        EndSection
      '';
      xkbOptions = "ctrl:nocaps";
      layout = "us";
    };
    avahi = {
      enable = true;
      nssmdns = true;
    };
    gnome = { gnome-keyring.enable = true; };
    journald.extraConfig = ''
      SystemMaxUse=500M
    '';
    logind.extraConfig = ''
      HandlePowerKey=suspend
    '';
    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        gutenprintBin
        foomatic-filters
        samsung-unified-linux-driver
      ];
    };
    resolved = {
      enable = true;
      dnssec = "false";
      extraConfig = ''
        DNS=45.90.28.0#.dns1.nextdns.io
        DNS=2a07:a8c0::#.dns1.nextdns.io
        DNS=45.90.30.0#.dns2.nextdns.io
        DNS=2a07:a8c1::#.dns2.nextdns.io
        DNSOverTLS=yes
      '';
    };
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = "haoxiangliew";
      dataDir = "/home/haoxiangliew/haoxiangliew";
      configDir = "/home/haoxiangliew/.config/syncthing";
    };
    udev = {
      packages = with pkgs; [
        android-udev-rules
        chrysalis
        logitech-udev-rules
        platformio
        qmk-udev-rules
        via
      ];
      extraRules = ''
        # increase trackpoint drift_time from 5 to 25
        SUBSYSTEM=="input", ATTR{name}=="TPPS/2 IBM TrackPoint", ATTR{device/drift_time}="25"

        # Serial Port Rules
        KERNEL=="ttyUSB[0-9]*", TAG+="udev-acl", TAG+="uaccess", OWNER="$1"
        KERNEL=="ttyACM[0-9]*", TAG+="udev-acl", TAG+="uaccess", OWNER="$1"

        # Arduino M0/M0 Pro, Primo UDEV Rules for CMSIS-DAP port
        ACTION!="add|change", GOTO="openocd_rules_end"
        SUBSYSTEM!="usb|tty|hidraw", GOTO="openocd_rules_end"
        ATTRS{product}=="*CMSIS-DAP*", MODE="664", GROUP="plugdev"
        LABEL="openocd_rules_end"

        # AVRisp UDEV rules
        SUBSYSTEM!="usb_device", ACTION!="add", GOTO="avrisp_end"
        # Atmel Corp. JTAG ICE mkII
        ATTR{idVendor}=="03eb", ATTRS{idProduct}=="2103", MODE="660", GROUP="dialout"
        # Atmel Corp. AVRISP mkII
        ATTR{idVendor}=="03eb", ATTRS{idProduct}=="2104", MODE="660", GROUP="dialout"
        # Atmel Corp. Dragon
        ATTR{idVendor}=="03eb", ATTRS{idProduct}=="2107", MODE="660", GROUP="dialout"
        LABEL="avrisp_end"

        # STM32 bootloader mode UDEV rules
        ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="664", GROUP="plugdev", TAG+="uaccess"

        # Arduino 101 in DFU Mode
        SUBSYSTEM=="tty", ENV{ID_REVISION}=="8087", ENV{ID_MODEL_ID}=="0ab6", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0"
        SUBSYSTEM=="usb", ATTR{idVendor}=="8087", ATTR{idProduct}=="0aba", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1"

        # allow "dialout" group read/write access to ADI PlutoSDR devices
        # DFU Device
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0456", ATTRS{idProduct}=="b674", MODE="0664", GROUP="dialout"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="2fa2", ATTRS{idProduct}=="5a32", MODE="0664", GROUP="dialout"
        # SDR Device
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0456", ATTRS{idProduct}=="b673", MODE="0664", GROUP="dialout"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="2fa2", ATTRS{idProduct}=="5a02", MODE="0664", GROUP="dialout"
        # tell the ModemManager (part of the NetworkManager suite) that the device is not a modem,
        # and don't send AT commands to it
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0456", ATTRS{idProduct}=="b673", ENV{ID_MM_DEVICE_IGNORE}="1"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="2fa2", ATTRS{idProduct}=="5a02", ENV{ID_MM_DEVICE_IGNORE}="1"
        # allow "dialout" group read/write access to ADI M2K devices
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0456", ATTRS{idProduct}=="b672", MODE="0664", GROUP="dialout"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0456", ATTRS{idProduct}=="b675", MODE="0664", GROUP="dialout"
        # tell the ModemManager (part of the NetworkManager suite) that the device is not a modem,
        # and don't send AT commands to it
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0456", ATTRS{idProduct}=="b672", ENV{ID_MM_DEVICE_IGNORE}="1"

        # Intel Quartus
        # USB-Blaster
        SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6001", MODE="0666", GROUP="usbblaster"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6002", MODE="0666", GROUP="usbblaster"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6003", MODE="0666", GROUP="usbblaster"
        # USB-Blaster II
        SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6010", MODE="0666", GROUP="usbblaster"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6810", MODE="0666", GROUP="usbblaster"

        # TI Code Composer Studio
        # MSP430UIF
        ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0010", MODE="0666"
        # MSP430EZ
        ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0013", MODE="0666"
        # MSP430MSPFET
        ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0014", MODE="0666"
        # MSP430HID
        ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0203", MODE="0666"
        # MSP430HID2
        ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0204", MODE="0666"
        # MSP430EZ430
        ATTRS{idVendor}=="0451", ATTRS{idProduct}=="f432", MODE="0666"

        # Texas Instruments USB devices
        SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="a6d0",MODE:="0666"
        SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="a6d1",MODE:="0666"
        SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="6010",MODE:="0666"
        SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="6011",MODE:="0666"
        SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="bcd9",MODE:="0666"
        SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="bcda",MODE:="0666"
        SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1cbe",ATTRS{idProduct}=="00fd",MODE:="0666"
        SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1cbe",ATTRS{idProduct}=="00ff",MODE:="0666"
        SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef1",MODE:="0666"
        SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef2",MODE:="0666"
        SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef3",MODE:="0666"
        SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef4",MODE:="0666"
        SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1cbe",ATTRS{idProduct}=="02a5",MODE:="0666"
        SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="c32a",MODE:="0666"
        ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef0",ENV{ID_MM_DEVICE_IGNORE}="1"
        ATTRS{idVendor}=="0c55",ATTRS{idProduct}=="0220",ENV{ID_MM_DEVICE_IGNORE}="1"
        KERNEL=="ttyACM[0-9]*",MODE:="0666"
        ACTION=="add",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="a6d0",RUN+="/sbin/modprobe ftdi_sio",RUN+="${pkgs.bash}/bin/sh -c 'echo 0403 a6d0 > /sys/bus/usb-serial/drivers/ftdi_sio/new_id'"
        ACTION=="add",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="a6d1",RUN+="/sbin/modprobe ftdi_sio",RUN+="${pkgs.bash}/bin/sh -c 'echo 0403 a6d1 > /sys/bus/usb-serial/drivers/ftdi_sio/new_id'"
        KERNEL=="hidraw*",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef3",MODE:="0666"
        KERNEL=="hidraw*",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef4",MODE:="0666"
        # Spectrum Digital USB devices
        SUBSYSTEM=="usb", ATTR{idVendor}=="0c55" ,ATTR{idProduct}=="0540", ATTR{manufacturer}=="Spectrum Digital Inc.",MODE="0666"
        SUBSYSTEM=="usb", ATTR{idVendor}=="0c55" ,ATTR{idProduct}=="0510", ATTR{manufacturer}=="Spectrum Digital, Inc.",MODE="0666"
        SUBSYSTEM=="usb", ATTR{idVendor}=="0c55" ,ATTR{idProduct}=="2000", ATTR{manufacturer}=="Spectrum Digital, Inc.",MODE="0666"
        SUBSYSTEM=="usb", ATTR{idVendor}=="0c55" ,ATTR{idProduct}=="0562",MODE="0666"
        SUBSYSTEM=="usb", ATTR{idVendor}=="0c55" ,ATTR{idProduct}=="0566",MODE="0666"

        # TI USB Emulators
        ACTION!="add|change", GOTO="mm_usb_device_blacklist_end"
        SUBSYSTEM!="usb", GOTO="mm_usb_device_blacklist_end"
        ENV{DEVTYPE}!="usb_device",  GOTO="mm_usb_device_blacklist_end"

        ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0010", ENV{ID_MM_DEVICE_IGNORE}="1"
        ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0010", ENV{MTP_NO_PROBE}="1"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0010", MODE:="0666"
        KERNEL=="ttyACM*", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0010", MODE:="0666"
        ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0013", ENV{ID_MM_DEVICE_IGNORE}="1"
        ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0013", ENV{MTP_NO_PROBE}="1"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0013", MODE:="0666"
        KERNEL=="ttyACM*", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0013", MODE:="0666"
        ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0014", ENV{ID_MM_DEVICE_IGNORE}="1"
        ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0014", ENV{MTP_NO_PROBE}="1"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0014", MODE:="0666"
        KERNEL=="ttyACM*", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0014", MODE:="0666"
        ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0203", ENV{ID_MM_DEVICE_IGNORE}="1"
        ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0203", ENV{MTP_NO_PROBE}="1"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0203", MODE:="0666"
        KERNEL=="ttyACM*", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0203", MODE:="0666"
        ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0204", ENV{ID_MM_DEVICE_IGNORE}="1"
        ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0204", ENV{MTP_NO_PROBE}="1"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0204", MODE:="0666"
        KERNEL=="ttyACM*", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0204", MODE:="0666"
        ATTRS{idVendor}=="0451", ATTRS{idProduct}=="f432", ENV{ID_MM_DEVICE_IGNORE}="1"
        ATTRS{idVendor}=="2047", ATTRS{idProduct}=="f432", ENV{MTP_NO_PROBE}="1"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="f432", MODE:="0666"
        KERNEL=="ttyACM*", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="f432", MODE:="0666"
        LABEL="mm_usb_device_blacklist_end"
      '';
    };
    btrfs.autoScrub.enable = true;
    earlyoom.enable = true;
    flatpak.enable = true;
    fstrim.enable = true;
    fwupd.enable = true;
    geoclue2.enable = true;
    openssh.enable = true;
    pcscd.enable = true;
    ratbagd.enable = true;
    upower.enable = true;
  };

  zramSwap.enable = true;

  systemd = {
    extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';
  };

  security = {
    protectKernelImage = true;
    polkit.enable = true;
    pki = {
      certificateFiles = [
        "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        "/home/haoxiangliew/haoxiangliew/hxSSH/server_rootCA.crt"
        "/home/haoxiangliew/haoxiangliew/hxSSH/NextDNS.cer"
        "/home/haoxiangliew/haoxiangliew/hxSSH/relay.pem"
      ];
    };
    rtkit.enable = true;
  };

  location.provider = "geoclue2";

  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  xdg = { portal = { enable = true; }; };

  users = {
    users.haoxiangliew = {
      createHome = true;
      home = "/home/haoxiangliew";
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [
        "wheel"
        "video"
        "audio"
        "dialout"
        "tty"
        "uucp"
        "plugdev"
        "usbblaster"
        "power"
        "disk"
        "networkmanager"
        "bluetooth"
        "adbusers"
        "lightdm"
        "libvirtd"
        "qemu"
      ];
    };
  };
}
