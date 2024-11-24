# boot vps with clonezilla disk
# run ocs-live-netcfg for net config
# allow root login in /etc/ssh/sshd_config
# set root password
# start ssh with systemctl start ssh

# build nixos
nix build .#nixosConfigurations.myhost.config.system.build.diskoImagesScript
# build disk image
./result
# write to remote disk
gzip -c main.raw | ssh -v root@85.215.151.157  "gunzip| dd of=/dev/vda  bs=1M"
# unmount clonezilla then reboot
