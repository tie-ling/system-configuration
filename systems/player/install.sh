# nixos-rebuild --option substituters https://mirror.sjtu.edu.cn/nix-channels/store

DISK=/dev/disk/by-id/nvme-BC711_NVMe_SK_hynix_128GB__CN0BN79341050C76B

# discard the entire block device
blkdiscard -f $DISK

nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount $PATH_TO_DISKO_IN_REPO

nixos-install --root /mnt --no-root-passwd --flake github:tie-ling/tconf#player

poweroff
