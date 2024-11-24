# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  modulesPath,
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

  # do not use hardened; interfere with amd sleep and power save
  imports = [
    (modulesPath + "/profiles/hardened.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  networking.hostName = "player"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  services.dnscrypt-proxy2 = {
    enable = true;
    upstreamDefaults = true;
    settings = {
      ipv6_servers = true;
    };
  };
  networking.useNetworkd = true;
  networking.nameservers = [ "127.0.0.1" ];

  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [ intel-media-driver ];
  # use alsa; which supports hdmi passthrough
  hardware.pulseaudio.enable = false;
  services.pipewire.enable = false;

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

  swapDevices = [
    {
      device = "/swapfile";
      size = 2048;
    }
  ];

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
