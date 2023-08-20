{ config, pkgs, lib, ... }:

{
  networking = {
    hostName = lib.mkForce "e595";
    dhcpcd.enable = false;
    networkmanager = {
      enable = true;
      ethernet.macAddress = "stable";
      wifi.macAddress = "stable";
    };
    firewall.enable = true;
  };

  nixpkgs.config = {
    allowUnfree = true;
    joypixels.acceptLicense = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    plymouth = {
      enable = true;
      font = "${pkgs.cantarell-fonts}/share/fonts/cantarell/Cantarell-VF.otf";
    };
    initrd.systemd.enable = true;
    supportedFilesystems = [ "btrfs" "ntfs" ];
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

  environment = {
    pathsToLink = [ "/libexec" ];
    systemPackages = with pkgs; [
      (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
      appimage-run
      aspell
      efibootmgr
      efitools
      enchant
      feh
      git
      htop
      hunspell
      hunspellDicts.en_US
      iftop
      libsecret
      lm_sensors
      mesa-demos
      mg
      mpv
      ncdu
      neofetch
      openssl
      p7zip
      parted
      psmisc
      ranger
      thefuck
      tree
      unrar
      unzip
      virtiofsd
      virt-manager
      virt-viewer
      wget
      win-virtio
      xdg-utils
      # devtools
      luaPackages.lua-lsp
      nil
      nixfmt
      nixpkgs-fmt
      nodePackages.bash-language-server
      nodePackages.yaml-language-server
      rnix-lsp
      shfmt
      stylua
    ];
  };

  programs = {
    adb.enable = true;
    captive-browser = {
      enable = true;
      interface = "wlp4s0";
    };
    dconf.enable = true;
    mtr.enable = true;
  };

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    bluetooth = {
      enable = true;
      powerOnBoot = false;
      settings = {
        General = {
          Experimental = "true";
          KernelExperimental = "true";
        };
      };
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
        mouse.accelProfile = "flat";
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
        DNS=45.90.28.0#nixos-5e65b4.dns1.nextdns.io
        DNS=2a07:a8c0::#nixos-5e65b4.dns1.nextdns.io
        DNS=45.90.30.0#nixos-5e65b4.dns2.nextdns.io
        DNS=2a07:a8c1::#nixos-5e65b4.dns2.nextdns.io
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
    mullvad-vpn = {
      enable = true;
      enableExcludeWrapper = false;
      package = pkgs.mullvad-vpn;
    };
    btrfs.autoScrub.enable = true;
    flatpak.enable = true;
    fwupd.enable = true;
    nfs.server.enable = true;
    pcscd.enable = true;
    ratbagd.enable = true;
    upower.enable = true;
    yubikey-agent.enable = true;
  };

  zramSwap.enable = true;

  systemd = {
    extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';
  };

  security = {
    polkit.enable = true;
    pki = {
      certificateFiles = [ "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];
    };
    rtkit.enable = true;
  };

  location.provider = "geoclue2";

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        ovmf.enable = true;
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
    lxd.enable = true;
  };
}
