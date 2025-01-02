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

set -u


# nixos-rebuild --option substituters https://mirror.sjtu.edu.cn/nix-channels/store
printf "put_my_text_password_here" > /tmp/secret.key
DISK=

# discard the entire block device
blkdiscard -f $DISK

nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount $PATH_TO_DISKO_IN_REPO

mkswap /dev/disk/by-partlabel/disk-main-encryptedSwap
swapon /dev/disk/by-partlabel/disk-main-encryptedSwap

nixos-install --root /mnt --no-root-passwd --flake $PATH_TO_REPO#MACHINE

umount -lr /mnt
zpool export -a

poweroff

# after login, before sway, clone home-config repo
git clone https://github.com/tie-ling/user-home-config
mv user-home-config/.git ~/
git reset --hard

# do not run sway, as at this time user services are failing
# reboot now!
reboot
# now everything should be working
