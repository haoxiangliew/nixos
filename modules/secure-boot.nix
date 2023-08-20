## Enable secure-boot on NixOS-unstable with Lanzaboote
# See https://nixos.wiki/wiki/Secure_Boot for more details

{ lib, ... }:

## Make sure bootspec is enabled in nixosConfigurations
# boot.bootspec.enable = true;

{
  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };
}
