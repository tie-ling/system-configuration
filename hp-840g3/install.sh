# To configure the wifi, first start wpa_supplicant with sudo systemctl start wpa_supplicant, then run wpa_cli. For most home networks, you need to type in the following commands:

# add_network
# 0
# set_network 0 ssid "myhomenetwork"
# OK
# set_network 0 psk "mypassword"
# OK
# set_network 0 key_mgmt WPA-PSK
# OK
# enable_network 0
# OK


# nixos-rebuild --option substituters https://mirror.sjtu.edu.cn/nix-channels/store
printf "put_my_text_password_here" > /root/diskpw
DISK=/dev/disk/by-id/nvme-SAMSUNG_MZVLV256HCHP-000H1_S2CSNA0J547878

# discard the entire block device
blkdiscard -f $DISK

# create empty gpt partition table
sgdisk --zap-all $DISK

# create three partitions, align both partition beginning and end
# for EFI system partition; linux and windows
sgdisk --align-end --new 1:0:+4G --new 2:0:0 --typecode 1:ef00 --typecode 2:8304 $DISK

sleep 1

# format esp
mkfs.vfat -n ESP ${DISK}-part1

# format encrypted root
cryptsetup --batch-mode luksFormat  --type luks2 --key-file=/root/diskpw ${DISK}-part2
cryptsetup luksOpen --allow-discards --key-file=/root/diskpw ${DISK}-part2 root

# format encrypted container
mkfs.xfs /dev/mapper/root

# mount root
mount /dev/mapper/root /mnt

# create swap
fallocate -l 8G /mnt/swapfile
chmod 0600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile

# mount esp as /boot
mkdir -p /mnt/boot
mount -o umask=077,iocharset=iso8859-1  ${DISK}-part1 /mnt/boot

nixos-install --root /mnt --no-root-passwd --flake github:tie-ling/tconf#hp-840g3

poweroff

# download gpg archive
curl -LO https://github.com/tie-ling/gpg/raw/main/gpg-2024-02-07.tar.xz
tar axf gpg-2024-02-07.tar.xz
mv $(find -name 'gpg' -type d) ~/.gnupg

# clone dotfiles repo
git clone https://github.com/tie-ling/alpine-dots
mv alpine-dots/.git ~/
git reset --hard

# enter Sway WM
sway

# clone config repo
git clone git@github.com:tie-ling/tconf

# clean up
rm -rf old gpg-2024* alpine-dots

# restart emacs
systemctl restart --user emacs

# clone repo
git clone git@github.com:tie-ling/passwd ~/.password-store
git clone git@github.com:tie-ling/tub ~/tub
git -C ~ remote rm origin
git -C ~ remote add origin git@github.com:tie-ling/alpine-dots
git -C ~ push -u origin main

# create mail dirs
mkdir -p ~/Mail/{posteo,gmail}
mu init --maildir ~/Mail --my-address yguo@posteo.net --my-address gyuchen86@gmail.com
mbsync -a
mu index
