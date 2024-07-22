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

  fileSystems."/" = {
    device = "npool/root";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "npool/home";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-id/ata-WDC_WD20EJRX-89G3VY0_WD-WCC4M4SUXL4D-part1";
    fsType = "vfat";
  };

  fileSystems."/rtorrent" = {
    device = "rtorrent";
    fsType = "zfs";
    options = [
      "X-mount.mkdir"
      "noatime"
      "nofail"
    ];
  };

  fileSystems."/home/our/新种子" = {
    device = "/rtorrent/watch";
    fsType = "none";
    options = [
      "bind"
      "X-mount.mkdir"
      "nofail"
    ];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-id/ata-WDC_WD20EJRX-89G3VY0_WD-WCC4M4SUXL4D-part3";
      randomEncryption = true;
    }
    {
      device = "/dev/disk/by-id/ata-WDC_WD20EJRX-89G3VY0_WD-WCC4M6ZPTJ7X-part3";
      randomEncryption = true;
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp108s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

}
