# Hao Xiang's NixOS Configuration

# { config, pkgs, ... }:

# hyper-v support
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.virtualisation.hypervGuest;

in {
  options = {
    virtualisation.hypervGuest = {
      enable = mkEnableOption "Hyper-V Guest Support";

      videoMode = mkOption {
        type = types.str;
        default = "1152x864";
        example = "1024x768";
        description = ''
          Resolution at which to initialize the video adapter.

          Supports screen resolution up to Full HD 1920x1080 with 32 bit color
          on Windows Server 2012, and 1600x1200 with 16 bit color on Windows
          Server 2008 R2 or earlier.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    boot = {
      initrd.kernelModules = [
        "hv_balloon" "hv_netvsc" "hv_storvsc" "hv_utils" "hv_vmbus"
      ];

      kernelParams = [
        "video=hyperv_fb:${cfg.videoMode} elevator=noop"
      ];
    };

    environment.systemPackages = [ config.boot.kernelPackages.hyperv-daemons.bin ];

    security.rngd.enable = false;

    # enable hotadding cpu/memory
    services.udev.packages = lib.singleton (pkgs.writeTextFile {
      name = "hyperv-cpu-and-memory-hotadd-udev-rules";
      destination = "/etc/udev/rules.d/99-hyperv-cpu-and-memory-hotadd.rules";
      text = ''
        # Memory hotadd
        SUBSYSTEM=="memory", ACTION=="add", DEVPATH=="/devices/system/memory/memory[0-9]*", TEST=="state", ATTR{state}="online"

        # CPU hotadd
        SUBSYSTEM=="cpu", ACTION=="add", DEVPATH=="/devices/system/cpu/cpu[0-9]*", TEST=="online", ATTR{online}="1"
      '';
    });

    systemd = {
      packages = [ config.boot.kernelPackages.hyperv-daemons.lib ];

      targets.hyperv-daemons = {
        wantedBy = [ "multi-user.target" ];
      };
    };
  };
}


# python
with pkgs;
let
  my-python-packages = python-packages: with python-packages; [
    # python packages
  ];
  python-with-my-packages = python3.withPackages my-python-packages;
in

{
  # imports
  imports =
    [
      ./hardware-configuration.nix
    ];

  # nixpkgs
  nixpkgs.config = {
    allowUnfree = true;

    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking
  networking.hostName = "nixos";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  time.timeZone = "America/New_York";

  # system packages
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable"; # rolling release
  environment.systemPackages = with pkgs; [
    firefox-bin
    git
    htop
    gimp
    neofetch
    alacritty
    vim
    pulseeffects
    pavucontrol
    wget
    fish
    fzf
    ripgrep
    tmux
    tree
    unrar
    unzip
    p7zip
    xloadimage
    vim

    # languages
    python-with-my-packages
    ghc
    nodejs

    # desktop
    xmobar
    dmenu
    feh
    libnotify
    lxqt.lxqt-notificationd
    scrot
    trayer
    xbrightness
    xcompmgr
    xorg.xrandr
    xorg.xbacklight
    xscreensaver
    xsettingsd
  ];

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      ubuntu_font_family
      cascadia-code
    ];
  };

  programs.dconf.enable = true;
  programs.light.enable = true;
  programs.vim.defaultEditor = true;

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # services

  # firewall
  # networking.firewall.allowedTCPPorts = [
  #   80
  #   443
  # ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;

  # CUPS
  services.printing.enable = true;

  # sound
  sound.enable = true;

  # hardware
  hardware = {
    pulseaudio.enable = true;
    acpilight.enable = true;
  };

  # X11
  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "amdgpu" ];
      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;

        # haskell packages
        extraPackages = hpkgs: [
          hpkgs.xmonad
          hpkgs.xmonad-contrib
          hpkgs.xmonad-extras
          hpkgs.xmonad-wallpaper
        ];
      };

      displayManager.defaultSession = "none+xmonad";
      desktopManager.xterm.enable = false;
      libinput.enable = true;
      layout = "us";
    };

    openssh.enable = true;
  };

  # users
  # don't forget to run passwd <username>
  users.users.haoxiangliew = {
    createHome = true;
    home = "/home/haoxiangliew";
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "video" "audio" "disk" "networkmanager" ];
  };


}
