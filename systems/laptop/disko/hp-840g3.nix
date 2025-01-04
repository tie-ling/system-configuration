(import ./configuration.nix) //
{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/nvme-SAMSUNG_MZVLV256HCHP-000H1_S2CSNA0J547878";
      };
    };
  };
}
