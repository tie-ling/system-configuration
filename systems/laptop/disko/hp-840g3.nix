{
  # see https://github.com/nix-community/disko/tree/master/example
  # in particular
  # https://github.com/nix-community/disko/blob/master/example/zfs-with-vdevs.nix
  # https://github.com/nix-community/disko/blob/master/example/zfs.nix
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-SAMSUNG_MZVLV256HCHP-000H1_S2CSNA0J547878";
        content = {
          type = "gpt";
          partitions = {
            # gpt-bios-compat
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            ESP = {
              size = "1024M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            encryptedSwap = {
              size = "8G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
            luks-root = {
              # contains swap file
              size = "64G";
              content = {
                type = "luks";
                name = "crypted-root";
                settings.allowDiscards = true;
                passwordFile = "/tmp/secret.key";
                content = {
                  type = "filesystem";
                  format = "xfs";
                  mountpoint = "/";
                };
              };
            };
            luks-home = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted-home";
                settings.allowDiscards = true;
                passwordFile = "/tmp/secret.key";
                content = {
                  type = "zfs";
                  pool = "zpool-home";
                };
              };
            };
          };
        };
      };
    };
    zpool = {
      zpool-home = {
        type = "zpool";
        # mode = one of "", "mirror", "raidz{1,2,3}"
        # see definition in https://github.com/nix-community/disko/blob/master/lib/types/zpool.nix
        mode = "";
        mountpoint = "/zpool-home";
        options.compatibility = "legacy";
        datasets = {
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
            options."com.sun:auto-snapshot" = "true";
          };
        };
      };
    };
  };
}
