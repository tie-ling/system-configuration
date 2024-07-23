# nixos-rebuild --option substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
# https://mirror.sjtu.edu.cn/nix-channels/store

DISK=/dev/disk/by-id/ata-SDEZS25-480G-Z01_183517455908

# discard the entire block device
blkdiscard -f $DISK

# create empty gpt partition table
sgdisk --zap-all $DISK

# create three partitions, align both partition beginning and end
# for EFI system partition; linux and windows
sgdisk --align-end --new 1:0:+4G --new 2:0:+256G --new 3:0:0 --typecode 1:ef00 --typecode 2:8304 --typecode 3:0700 $DISK

sleep 1

# format esp
mkfs.vfat -n ESP ${DISK}-part1

# format system partition
mkfs.xfs ${DISK}-part2

# mount root
mount ${DISK}-part2 /mnt

# create swap
fallocate -l 8G /mnt/swapfile
chmod 0600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile

# mount esp as /boot
mkdir -p /mnt/boot
mount -o umask=077,iocharset=iso8859-1  ${DISK}-part1 /mnt/boot

nixos-install --root /mnt --no-root-passwd --flake github:tie-ling/tconf#qinghe

poweroff
