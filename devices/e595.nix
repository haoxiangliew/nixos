# e595 nixOS device configuration

{ config, pkgs, lib, ... }:

{
  boot = {
    kernelParams = [ ];
    kernelModules = [ "thinkpad_acpi" "acpi_call" "kvm_amd" ];
    initrd.kernelModules = [ "amdgpu" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
    extraModprobeConfig = "";
    kernel.sysctl = { };
  };

  environment = { systemPackages = with pkgs; [ radeontop ]; };

  hardware = {
    cpu.amd.updateMicrocode = true;
    opengl = {
      extraPackages = with pkgs; [
        amdvlk
        libva
        libvdpau
        libvdpau-va-gl
        mesa
        rocm-opencl-icd
        rocm-opencl-runtime
        vaapiVdpau
      ];
      extraPackages32 = with pkgs.driversi686Linux; [
        amdvlk
        mesa
        libvdpau-va-gl
        vaapiVdpau
      ];
    };
  };

  services = { xserver = { videoDrivers = [ "amdgpu" ]; }; };
}
