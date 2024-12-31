# Example to create a bios compatible gpt partition
{ pkgs, modulesPath, ... }:
let
  mypy = pkgs.python3.withPackages (python-pkgs: [
    python-pkgs.playwright
    python-pkgs.pytest-playwright
    python-pkgs.pytest
    python-pkgs.requests
    python-pkgs.notmuch
  ]);
in
{
  boot.loader.grub = {
    enable = true;
  };

  imports = [
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/hardened.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  security.apparmor.enable = true;
  security.apparmor.killUnconfinedConfinables = true;
  systemd.network.enable = true;
  networking.useNetworkd = true;

  time.timeZone = "Europe/Berlin";
  zramSwap.enable = true;

  networking.firewall.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
    allowSFTP = true;
    openFirewall = true;

  };

  boot.initrd.availableKernelModules = [
    "virtio_net"
    "virtio_pci"
    "virtio_blk"
  ];

  swapDevices = [
    {
      device = "/swapfile";
      size = 1024;
    }
  ];
  services.changedetection-io = {
    enable = false;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.getty.autologinUser = "root";
  boot.initrd.systemd.enable = true;
  networking.hostName = "vps"; # Define your hostname.

  programs.git.enable = true;
  users.mutableUsers = false;
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAwcU205j7zIq6IfbJ14G3FcKaIs979qC8NPyxVFhd71 yc@dell-7300"
    ];
  };
  users.users.autow.group = "autow";
  users.groups.autow = { };
  users.users.autow = {
    createHome = true;
    home = "/var/lib/autow";
    isSystemUser = true;
    packages =
      with pkgs;
      [
        playwright
        playwright-driver.browsers
        isync
        notmuch
      ]
      ++ [ mypy ];

  };

  systemd.timers."autow" = {
    wantedBy = [ "default.target" ];
    timerConfig = {
      # between mon to fri; between 08 and 20; every 20 minutes
      OnCalendar = "*-*-* 07..22:0/5:00";
      RandomizedDelaySec = "3m";
      Unit = "autow.service";
    };
  };
  environment.systemPackages = with pkgs; [
    # mini emacs with utf8 support
    # multi-buffer, multi-window
    # https://bellard.org/qemacs/
    qemacs
  ];

  systemd.services."autow" = {
    path =
      with pkgs;
      [
        playwright
        playwright-driver.browsers
      ]
      ++ [ mypy ];
    serviceConfig = {
      Type = "simple";
      User = "autow";
      WorkingDirectory = "/var/lib/autow";
      Environment = "PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers} PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true";
      ExecStart = ''${mypy}/bin/python3 /var/lib/autow/start.py fill_main'';
    };
  };
  security.chromiumSuidSandbox.enable = true;
  systemd.services.isync = {
    description = "Free IMAP and MailDir mailbox synchronizer";
    serviceConfig = {
      User = "autow";
      WorkingDirectory = "/var/lib/autow";

      Type = "oneshot";
      ExecStart = "${pkgs.isync}/bin/mbsync --all --quiet";
      ExecStartPost = "${pkgs.notmuch}/bin/notmuch new --decrypt=false";
      TimeoutStartSec = "360s";
    };
    path = [
      pkgs.notmuch
      mypy
    ];
  };
  systemd.timers.isync = {
    description = "isync timer";
    timerConfig = {
      Unit = "isync.service";
      OnCalendar = "*:0/5";
    };
    wantedBy = [ "default.target" ];
  };
  systemd.timers."prc" = {
    wantedBy = [ "default.target" ];
    timerConfig = {
      # between mon to fri; between 08 and 20; every 20 minutes
      OnCalendar = "*:0/10";
      Unit = "prc.service";
    };
  };
  systemd.services."prc" = {
    path =
      with pkgs;
      [
        playwright
        playwright-driver.browsers
        notmuch
        isync
      ]
      ++ [ mypy ];
    serviceConfig = {
      Type = "simple";
      User = "autow";
      WorkingDirectory = "/var/lib/autow";
      Environment = "PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers} PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true";
      ExecStart = ''${mypy}/bin/python3 /var/lib/autow/prc.py'';
    };
  };

  disko.devices = {
    disk = {
      main = {
        device = "/dev/vda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
