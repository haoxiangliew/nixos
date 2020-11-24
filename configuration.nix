# Hao Xiang's NixOS Configuration

{ config, pkgs, ... }:

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
  };

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "acpi_backlight=vendor" ];
  boot.kernelModules = [ "tp_smapi" "thinkpad_acpi" "acpi_call" ];

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
  environment.systemPackages = with pkgs; [
    arc-theme
    acpilight
    curl
    ffmpeg
    google-chrome
    git
    htop
    gimp
    gnupg
    neofetch
    alacritty
    vim
    mpv
    pulseeffects
    pavucontrol
    parted
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
    xloadimage
    vim

    # languages
    gcc
    gnumake
    cmake
    python-with-my-packages
    ghc
    nodejs

    # desktop
    xmobar                    # bar for xmonad
    dmenu                     # menu for xmonad
    networkmanager_dmenu      # network manager
    j4-dmenu-desktop          # .desktop in dmenu
    lxappearance              # gtk theme settings
    scrot                     # screenshots
    xbrightness               # brightness control
    xorg.xorgserver           # X11
    xorg.xf86inputlibinput    # libinput
    xorg.xf86videoati         # AMD driver
    physlock                  # lockscreen
    xautolock                 # lock daemon
    xcompmgr                  # compositor
    xorg.xrandr               # cli xrandr extension
    arandr                    # xrandr settings
    xorg.xbacklight           # backlight
    xscreensaver              # screensaver
    xsettingsd                # desktop settings server

  ];

  fonts = {
    # change to fontDir.enable after changing to rolling
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
    opengl.enable = true;
    opengl.driSupport = true;
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
      libinput.accelProfile = "flat";
      config = ''
        Section "InputClass"
          Identifier "mouse accel"
          Driver "libinput"
          MatchIsPointer "on"
          Option "AccelProfile" "flat"
          Option "AccelSpeed" "0"
        EndSection
      '';
      layout = "us";
    };
    physlock = {
      enable = true;
      allowAnyUser = true;
    };
    tlp.enable = true;
    openssh.enable = true;
    syncthing = {
      enable = true;
      user = "haoxiangliew";
      dataDir = "/home/haoxiangliew/haoxiangliew";
      configDir = "/home/haoxiangliew/.config/syncthing";
    };
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
