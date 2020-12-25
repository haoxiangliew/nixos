# Hao Xiang's NixOS Configuration

{ config, pkgs, ... }:

# python
with pkgs;
let
  my-python-packages = python-packages:
    with python-packages;
    [
      # python packages
    ];
  python-with-my-packages = python3.withPackages my-python-packages;

in {
  # imports
  imports = [ ./hardware-configuration.nix ./cachix.nix ];

  # nixpkgs
  nixpkgs.config = { allowUnfree = true; };

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelParams = [ "iommu=soft" "acpi_backlight=video" ];
  boot.kernelModules = [ "thinkpad_acpi" "tcp_bbr" "acpi_call" ];
  boot.kernel.sysctl."net.ipv4.tcp_fastopen" = "3";
  boot.kernel.sysctl."net.core.default_qdisc" = "fq";
  boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";

  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  boot.supportedFilesystems = [ "ntfs" ];
  boot.plymouth.enable = true;

  # networking
  networking.hostName = "nixos";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;
  # local dns resolver configuration
  networking.nameservers = [ "127.0.0.1" "::1" ];
  networking.resolvconf.useLocalResolver = true;
  networking.networkmanager.dns = "none";
  networking.networkmanager.ethernet.macAddress = "random";
  networking.networkmanager.wifi.macAddress = "random";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ libpinyin ];
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  time.timeZone = "America/Los_Angeles";

  # system packages
  environment.systemPackages = with pkgs; [
    (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
    microcodeAmd
    arc-theme
    acpilight
    binutils
    blueman
    curl
    ffmpeg
    google-chrome
    git
    htop
    libreoffice-fresh
    hunspell
    hunspellDicts.en_US
    gimp
    gnupg
    libva
    libva-utils
    vdpauinfo
    lm_sensors
    neofetch
    alacritty
    vim
    mpv
    openssl
    stubby
    numlockx
    pulseeffects
    pavucontrol
    parted
    psmisc
    wget
    fd
    fish
    fzf
    ranger
    ripgrep
    syncthing
    thefuck
    tlp
    tmux
    tree
    unrar
    unzip
    p7zip
    feh
    vim
    usbutils
    pciutils

    # languages
    gcc
    gnumake
    cmake
    python-with-my-packages
    ghc
    nodejs

    # desktop
    xmobar # bar for xmonad
    dmenu # menu for xmonad
    fwupd # firmware manager
    networkmanager_dmenu # network manager
    j4-dmenu-desktop # .desktop in dmenu
    lxappearance # gtk theme settings
    libnotify # notifications
    notify-osd # notification daemon
    maim # screenshots
    xclip # cli clipboard manager
    xbrightness # brightness control
    xorg.xorgserver # X11
    xorg.xf86inputlibinput # libinput
    xorg.xf86videoati # AMD driver
    physlock # lockscreen
    xautolock # lock daemon
    picom # compositor
    xorg.xrandr # cli xrandr extension
    arandr # xrandr settings
    xorg.xbacklight # backlight
    xsettingsd # desktop settings server

  ];

  fonts = {
    # change to fontDir.enable after changing to rolling
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      ubuntu_font_family
      cascadia-code
      noto-fonts-emoji
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Times New Roman" ];
        sansSerif = [ "Ubuntu" ];
        monospace = [ "Cascadia Code" ];
      };
    };
  };

  programs.dconf.enable = true;
  programs.light.enable = true;
  programs.vim.defaultEditor = true;
  programs.fish.enable = true;
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # services

  # firewall
  networking.firewall.allowedTCPPorts = [ 80 443 22000 3000 ];
  networking.firewall.allowedUDPPorts = [ 21027 32410 32412 32413 32414 ];
  networking.firewall.enable = true;

  # sound
  sound.enable = true;

  # hardware
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    pulseaudio = {
      enable = true;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      package = pkgs.pulseaudioFull;
      daemon.config = {
        default-fragments = 2;
        default-fragment-size-msec = 5;
      };
    };
    enableRedistributableFirmware = true;
    acpilight.enable = true;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [ mesa vaapiVdpau libvdpau-va-gl ];
    };
  };

  # X11
  services = {
    xserver = {
      enable = true;
      # hyper-v support
      # modules = [
      #   pkgs.xorg.xf86videofbdev
      # ];
      # videoDrivers = [ "hyperv_fb" ];
      videoDrivers = [ "amdgpu" ];
      deviceSection = ''
        Option "TearFree" "true"
      '';
      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;

        # haskell packages
        extraPackages = hpkgs: [
          hpkgs.xmonad
          hpkgs.xmonad-contrib
          hpkgs.xmonad-extras
          hpkgs.xmonad-wallpaper
          hpkgs.xmonad-spotify
        ];
      };

      xautolock = {
        enable = true;
        killtime = 20;
        killer = "/run/current-system/systemd/bin/systemctl suspend";
        time = 15;
        locker = "${config.security.wrapperDir}/physlock -dms";
        nowlocker = "${config.security.wrapperDir}/physlock -dms";
        enableNotifier = true;
        notify = 10;
        notifier =
          ''${pkgs.libnotify}/bin/notify-send "Locking in 10 seconds"'';
        extraOptions = [ "-detectsleep" ];
      };
      displayManager.defaultSession = "none+xmonad";
      displayManager.lightdm = {
        enable = true;
        background = pkgs.nixos-artwork.wallpapers.dracula.gnomeFilePath;
      };
      displayManager.lightdm.greeters.gtk = {
        enable = true;
        clock-format = "%H:%M:%S";
        theme = {
          name = "Arc-Dark";
          package = pkgs.arc-theme;
        };
        extraConfig = ''
          position=200,start 50%,center
        '';
      };
      desktopManager.xterm.enable = false;
      libinput.enable = true;
      libinput.disableWhileTyping = true;
      libinput.accelProfile = "flat";
      libinput.naturalScrolling = true;
      libinput.additionalOptions = ''MatchIsTouchpad "on"'';
      config = ''
        Section "InputClass
          Identifier "mouse accel"
          Driver "libinput"
          MatchIsPointer "on"
          Option "AccelProfile" "flat"
          Option "AccelSpeed" "0"
        EndSection
      '';
      layout = "us";
    };
    blueman.enable = true;
    # dns resolver
    stubby = {
      enable = true;
      roundRobinUpstreams = false;
      upstreamServers = ''
        - address_data: 45.90.28.0
          tls_auth_name: "nixos-######.dns1.nextdns.io"
        - address_data: 2a07:a8c0::0
          tls_auth_name: "nixos-######.dns1.nextdns.io"
        - address_data: 45.90.30.0
          tls_auth_name: "nixos-######.dns2.nextdns.io"
        - address_data: 2a07:a8c1::0
          tls_auth_name: "nixos-######.dns2.nextdns.io"
      '';
    };
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        USB_AUTOSUSPEND = 0;
      };
    };
    fstrim.enable = true;
    fwupd.enable = true;
    logind.extraConfig = ''
      HandlePowerKey=suspend
    '';
    openssh.enable = true;
    physlock = {
      enable = true;
      allowAnyUser = true;
    };
    avahi.enable = true;
    avahi.publish.userServices = true;
    avahi.nssmdns = true;
    printing.enable = true;
    printing.drivers = with pkgs; [
      gutenprint
      gutenprintBin
      foomatic-filters
      samsungUnifiedLinuxDriver
    ];
    syncthing = {
      enable = true;
      user = "haoxiangliew";
      dataDir = "/home/haoxiangliew/haoxiangliew";
      configDir = "/home/haoxiangliew/.config/syncthing";
    };
  };

  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
       if (action.id == "org.freedesktop.login1.suspend" ||
           action.id == "org.freedesktop.login1.suspend-multiple-sessions" ||
           action.id == "org.freedesktop.login1.set-wall-message")
       {
         return polkit.Result.YES;
       }
    });
  '';

  powerManagement.enable = true;

  virtualisation.virtualbox.host.enable = true;

  # users
  # don't forget to run passwd <username>
  users.users.haoxiangliew = {
    createHome = true;
    home = "/home/haoxiangliew";
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "power"
      "disk"
      "networkmanager"
      "bluetooth"
      "vboxusers"
    ];
  };
}
