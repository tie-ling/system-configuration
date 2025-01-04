{
  boot.loader.grub.enable = true;
  boot.loader.systemd-boot.enable = false;
  # coreboot has issues with video initialization;
  # thus load i915 in initrd
  boot.initrd.availableKernelModules = [
    "i915"
  ];

  # battery care with tlp
  # https://linrunner.de/tlp/settings/bc-vendors.html
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 50;
      STOP_CHARGE_THRESH_BAT0 = 60;
    };
  };

  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/ata-Micron_5100_MTFDDAK480TBY_18271D3D0DD1";
      };
    };
  };
}
