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
