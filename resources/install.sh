# To configure the wifi, first start wpa_supplicant with sudo systemctl start wpa_supplicant, then run wpa_cli. For most home networks, you need to type in the following commands:

# systemctl start wpa_supplicant
# wpa_cli
# add_network
# 0
# set_network 0 ssid "myhomenetwork"
# OK
# set_network 0 psk "mypassword"
# OK
# enable_network 0
# OK

set -u


# nixos-rebuild --option substituters https://mirror.sjtu.edu.cn/nix-channels/store
printf "put_my_text_password_here" > /tmp/secret.key

# double check password
cat /tmp/secret.key

find /dev/disk/by-id/
DISK=

# discard the entire block device
blkdiscard -f $DISK

git clone https://github.com/tie-ling/system-configuration

nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ./system-configuration/systems/laptop/disko/$MACHINE.nix

cryptsetup open --batch-mode --type plain --key-file=/dev/random /dev/disk/by-partlabel/disk-main-encryptedSwap encryptedSwap
mkswap /dev/mapper/encryptedSwap
swapon /dev/mapper/encryptedSwap

nixos-install --root /mnt --no-root-passwd --flake ./system-configuration#$MACHINE

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

# restore gpg keys to ~/.gnupg
tar axf $HOME/.password-store/gpg/gnupg-20241231.tar.xz -C $HOME

# setup chrome: install browserpass, ublock, enhanced h264ify; disable js
