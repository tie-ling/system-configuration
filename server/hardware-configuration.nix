{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{

  imports = [
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/hardened.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "uas"
    "sd_mod"
    "nvme"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-id/ata-WDC_WD20EJRX-89G3VY0_WD-WCC4M6ZPTJ7X-part1";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-id/ata-WDC_WD20EJRX-89G3VY0_WD-WCC4M6ZPTJ7X-part2";
    fsType = "xfs";
  };


  fileSystems."/disks/1" = {
    device = "/dev/disk/by-id/ata-WDC_WD20EJRX-89G3VY0_WD-WCC4M6ZPTJ7X-part2";
    fsType = "xfs";
  };

  fileSystems."/disks/2" = {
    device = "/dev/disk/by-id/ata-WDC_WD20EJRX-89G3VY0_WD-WCC4M0ZH64T7-part2";
    fsType = "xfs";
  };

  fileSystems."/disks/3" = {
    device = "/dev/disk/by-id/ata-WDC_WD20EJRX-89G3VY0_WD-WCC4M4SUXL4D-part2";
    fsType = "xfs";
  };

  # parity disk
  fileSystems."/disks/4" = {
    device = "/dev/disk/by-id/ata-WDC_WD20EZRX-00D8PB0_WD-WCC4M1455922-part2";
    fsType = "xfs";
  };

  fileSystems."/mergerfs" = {
    fsType = "fuse.mergerfs";
    device = "/disks/1:/disks/2:/disks/3";
    options = ["cache.files=off" "dropcacheonclose=true" "category.create=mfs"];
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp108s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
