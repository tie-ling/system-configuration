{
  imports = [ ./configuration.nix ];
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/ata-Micron_5100_MTFDDAK480TBY_18271D3D0DD1";
      };
    };
  };
}
