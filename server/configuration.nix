{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  options = {
    services.i2pd.logLevel = lib.mkOption {
      type = lib.types.enum [
        "debug"
        "info"
        "warn"
        "error"
        "critical"
        "none"
      ];
    };
  };
  config = {

    boot.loader.systemd-boot.enable = true;

    boot.loader.efi.canTouchEfiVariables = true;

    security.lockKernelModules = false;

    nix.settings.substituters = lib.mkBefore [ "https://mirror.sjtu.edu.cn/nix-channels/store" ];

    networking.hostId = "abcd1234";
    time.timeZone = "Asia/Shanghai";

    programs.tmux = {
      enable = true;
      keyMode = "emacs";
      newSession = true;
      terminal = "tmux-direct";
      extraConfig = ''
        unbind C-b
        unbind f7
        set -u prefix
        set -g prefix f7
        bind -N "Send the prefix key" f7 send-prefix
      '';
    };

    zramSwap.enable = true;

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    boot.initrd.systemd.enable = true;

    programs.git.enable = true;

    networking = {
      hostName = "tieling";
      firewall.enable = true;
      nameservers = [ "127.0.0.1" ];
      networkmanager = {
        enable = true;
        dns = "none";
      };
    };

    nix.registry.nixpkgs.flake = inputs.nixpkgs;

    users.mutableUsers = false;

    # Most users should NEVER change this value after the initial install, for any reason,
    # even if you've upgraded your system to a new NixOS release.

    system.stateVersion = "23.11"; # Did you read the comment?

    users.users = {
      root = {
        initialHashedPassword = "$y$j9T$odRyg2xqJbySHei1UBsw3.$AxuY704CGICLQqKPm3wiV/b7LVOVSMKnV4iqK1KvAk2";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWeAeIuIf2Zyv+d+J6ZWGuKx1lmKFa6UtzCTNtB5+Ev openpgp:0x1FD7B98A"
        ];
      };
      our = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWeAeIuIf2Zyv+d+J6ZWGuKx1lmKFa6UtzCTNtB5+Ev openpgp:0x1FD7B98A"
        ];
      };
      yc = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWeAeIuIf2Zyv+d+J6ZWGuKx1lmKFa6UtzCTNtB5+Ev openpgp:0x1FD7B98A"
        ];
      };
    };
    environment = {
      systemPackages = builtins.attrValues { inherit (pkgs) smartmontools darkhttpd emacs-nox; };
    };

    networking.firewall = {
      # ports are also opened by other programs
      # open ports temporarily with nixos-firewall-tool
      allowedTCPPorts = [
        # nfsv4
        2049
      ];
      allowedUDPPorts = [ ];
    };

    services = {
      # workaround for hardened profile
      logrotate.checkConfig = false;
      zfs = {
        autoScrub = {
          enable = true;
          interval = "quarterly";
        };
      };
      # nfs4 does not need rpcbind
      rpcbind.enable = lib.mkForce false;
      nfs = {
        # kodi/coreelec uses nfs3 by default
        # switch to nfs4 by using settings here
        # https://kodi.wiki/view/Settings/Services/NFS_Client

        # NO ENCRYPTION, CLEAR TEXT!
        # use for only public shares or tunnel through something like ssh
        server = {
          enable = true;
          createMountPoints = true;
          exports = ''
            /rtorrent    192.168.1.0/24(ro,all_squash)
          '';
        };
        settings = {
          nfsd.vers3 = false;
          nfsd.vers4 = true;
        };
      };
      samba-wsdd.enable = false;
      samba = {
        enable = true;
        openFirewall = true;
        # add user password with
        # printf 'woxiang\nwoxiang' | smbpasswd -s -a our
        # saves to /var/lib/samba

        # 用windows电脑建立连接：此电脑->映射网络驱动器->输入
        # \\192.168.1.192\bt，勾选“使用其他凭据”，输入用户名our和密码。
        # 必须直接输入ip地址来建立连接，基于安全原因，自动探索模式和访客
        # 已被禁用。
        enableNmbd = false;
        enableWinbindd = false;
        extraConfig = ''
          map to guest = Never
          server smb encrypt = required
          server min protocol = SMB3
        '';
        shares = {
          our = {
            path = "/home/our";
            "read only" = false;
            "hosts allow" = "192.168.1.";
          };
          bt = {
            path = "/rtorrent/已下载";
            "read only" = true;
            "hosts allow" = "192.168.1.";
          };
        };
      };
      transmission = {
        enable = true;
        home = "/rtorrent";
        downloadDirPermissions = "755";
        openFirewall = true;
        performanceNetParameters = true;
        settings = {
          download-dir = "${config.services.transmission.home}/已下载";
          incomplete-dir = "${config.services.transmission.home}/未完成";
          incomplete-dir-enabled = true;
          watch-dir = "${config.services.transmission.home}/添加种子";
          watch-dir-enabled = true;
          trash-original-torrent-files = true;
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
      tlp.enable = true;
      tor = {
        enable = true;
        client = {
          enable = true;
          dns.enable = true;
        };
        relay = {
          enable = false;
          onionServices = {
            ssh = {
              authorizedClients = [ ];
              map = [
                {
                  port = 22;
                  target = {
                    addr = "[::1]";
                    port = 22;
                  };
                }
              ];
            };
          };
        };
        settings = {
          ClientUseIPv6 = true;
          ClientPreferIPv6ORPort = true;
          ClientUseIPv4 = true;
          UseBridges = 0;
          Bridge = [ ];
          Sandbox = true;
          SafeSocks = 1;
          NoExec = 1;
        };
      };
      i2pd = {
        enable = true;
        enableIPv4 = true;
        enableIPv6 = true;
        bandwidth = 40960;
        logLevel = "none";
        floodfill = true;
        inTunnels = {
          ssh-server = {
            enable = true;
            address = "::1";
            destination = "::1";
            port = 22;
            accessList = [ ]; # to lazy to only allow my laptops
          };
        };
      };
      yggdrasil = {
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
      dnscrypt-proxy2 = {
        enable = true;
        upstreamDefaults = true;
        settings = {
          ipv6_servers = true;
        };
      };
      sanoid = {
        enable = true;
        datasets = {
          "npool/home" = {
            autosnap = true;
            autoprune = true;
            hourly = 2;
            daily = 3;
            monthly = 6;
          };
        };
      };
    };
  };
}
