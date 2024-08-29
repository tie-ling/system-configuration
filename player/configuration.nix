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
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.memtest86.enable = true;

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

  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [ intel-media-driver ];
  # use alsa; which supports hdmi passthrough
  hardware.pulseaudio.enable = false;
  services.pipewire.enable = false;
  sound.enable = true;

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
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
      };
      allowSFTP = true;
      openFirewall = true;
    };
    logind = {
      extraConfig = ''
        HandlePowerKey=poweroff
      '';
      lidSwitch = "suspend";
      lidSwitchDocked = "ignore";
      lidSwitchExternalPower = "suspend";
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
      description = "Yuchen Guo";
      extraGroups = [
        # use doas
        "wheel"
        # allow kodi access to keyboards
        "input"
      ];
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILHRLlcqy8eop434Tew/QgLhz2Qxm/WsXuiF3UQHtPPK yc@yinzhou"
      ];
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
    kodi-gbm
  ];

  services.getty.autologinUser = "yc";

  system.stateVersion = "24.05"; # Did you read the comment?

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${pkgs.kodi-gbm}/bin/kodi-standalone";
        user = "yc";
      };
      default_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd sway";
      };
    };
  };
  programs.sway = {
    enable = true;
    xwayland.enable = false;
  };
  services.yggdrasil = {
    persistentKeys = true;
    enable = true;
    openMulticastPort = false;
    extraArgs = [
      "-loglevel"
      "error"
    ];
    settings.Peers =
      #curl -o test.html https://publicpeers.neilalexander.dev/
      # grep -e 'tls://' -e 'tcp://' -e 'quic://' test.html | grep online | sed 's|<td id="address">|"|' | sed 's|</td><td.*|"|g' | sort | wl-copy -n
      (import ../yggdrasil-peers.nix);
  };
}
