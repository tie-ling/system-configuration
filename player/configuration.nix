# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{

  boot.loader.systemd-boot.enable = true;

  boot.loader.efi.canTouchEfiVariables = true;

  services.logrotate.checkConfig = false;
  environment.memoryAllocator.provider = "libc";
  security.lockKernelModules = false;

  nix.settings.substituters = [ "https://mirror.sjtu.edu.cn/nix-channels/store" ];

  networking.hostName = "player"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  services = {
    tlp = {
      enable = true;
      settings = {
        DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "bluetooth wwan";
        STOP_CHARGE_THRESH_BAT0 = 1;
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        CPU_BOOST_ON_BAT = 0;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;
        # treat everything as battery
        TLP_DEFAULT_MODE = "BAT";
        TLP_PERSISTENT_DEFAULT = 1;
      };
    };
    logind = {
      extraConfig = ''
        HandlePowerKey=suspend
      '';
      lidSwitch = "suspend";
      lidSwitchDocked = "ignore";
      lidSwitchExternalPower = "suspend";
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };
  security = {
    doas.enable = true;
    sudo.enable = false;
  };

  zramSwap.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.initrd.systemd.enable = true;

  programs.git.enable = true;

  networking = {
    firewall.enable = true;
  };
  users.mutableUsers = false;
  users.users = {
    yc = {
      initialHashedPassword = "$6$UxT9KYGGV6ik$BhH3Q.2F8x1llZQLUS1Gm4AxU7bmgZUP7pNX6Qt3qrdXUy7ZYByl5RVyKKMp/DuHZgk.RiiEXK8YVH.b2nuOO/";
      packages = with pkgs; [ kodi-gbm ];
      description = "Yuchen Guo";
      extraGroups = [
        # use doas
        "wheel"
      ];
      isNormalUser = true;
    };
  };
  fonts.packages = builtins.attrValues {
    inherit (pkgs)
      dejavu_fonts
      noto-fonts-cjk-sans
      gyre-fonts
      stix-two
      julia-mono
      ;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    mg
    # create secure boot keys
    sbctl
    powertop
  ];

  services.getty.autologinUser = "yc";

  system.stateVersion = "24.05"; # Did you read the comment?

  boot.extraModprobeConfig = ''
    options snd-hda-intel patch=hda-jack-retask.fw
  '';

  hardware.firmware = [
    (pkgs.writeTextDir "/lib/firmware/hda-jack-retask.fw" ''
      [codec]
      0x8086280b 0x80860101 2

      [pincfg]
      0x05 0x18560070
      0x06 0x18560070
      0x07 0x18560070
    '')
  ];

}
