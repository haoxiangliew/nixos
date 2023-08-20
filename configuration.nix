{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixos";

  nix.settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-users = [ "@wheel" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
  };

  system.stateVersion = config.system.nixos.release;

  boot.loader.systemd-boot.enable = true;

  environment.systemPackages = with pkgs; [
    # Flakes use Git to pull dependencies from data sources, so Git must be installed first
    curl
    git
    vim
    wget
  ];
}
