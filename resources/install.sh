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

nixos-install --root /mnt --no-root-passwd --flake github:tie-ling/tconf#hp-840g3

poweroff
