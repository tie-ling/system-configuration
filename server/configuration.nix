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
    boot.loader.systemd-boot.editor = false;
    boot.loader.systemd-boot.memtest86.enable = true;

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
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMdVFa8xiHlDR9keRNERhNysEfdLrk/oKOFc+U8bQFAE u0_a298@localhost"
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

    systemd.services.rtorrent.serviceConfig.LimitNOFILE = 10240;

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
            path = "/rtorrent/download";
            "read only" = true;
            "hosts allow" = "192.168.1.";
          };
        };
      };
      flood = {
        enable = true;
      };
      rtorrent = {
        enable = true;
        dataDir = "/rtorrent/";
        downloadDir = "/rtorrent/download";
        openFirewall = true;
        port = 50000;
        dataPermissions = "0755";
        configText = lib.mkForce ''
          #############################################################################
          # A minimal rTorrent configuration that provides the basic features
          # you want to have in addition to the built-in defaults.
          #
          # See https://github.com/rakshasa/rtorrent/wiki/CONFIG-Template
          # for an up-to-date version.
          #############################################################################

          # Instance layout (base paths)
          method.insert = cfg.basedir,  private|const|string, (cat,"/rtorrent/")
          method.insert = cfg.download, private|const|string, (cat,(cfg.basedir),"download/")
          method.insert = cfg.logs,     private|const|string, (cat,(cfg.basedir),"log/")
          method.insert = cfg.logfile,  private|const|string, (cat,(cfg.logs),"rtorrent-",(system.time),".log")
          method.insert = cfg.session,  private|const|string, (cat,(cfg.basedir),".session/")
          method.insert = cfg.watch,    private|const|string, (cat,(cfg.basedir),"watch/")

          # Create instance directories
          execute.throw = sh, -c, (cat,\
              "mkdir -p \"",(cfg.download),"\" ",\
              "\"",(cfg.logs),"\" ",\
              "\"",(cfg.session),"\" ",\
              "\"",(cfg.watch),"/load\" ",\
              "\"",(cfg.watch),"/start\" ")

          # Listening port for incoming peer traffic (fixed; you can also randomize it)
          network.port_range.set = 50000-50000
          network.port_random.set = no

          # Peer settings
          throttle.max_uploads.set = 100
          throttle.max_uploads.global.set = 250

          throttle.min_peers.normal.set = 20
          throttle.max_peers.normal.set = 60
          throttle.min_peers.seed.set = 30
          throttle.max_peers.seed.set = 80
          trackers.numwant.set = 80

          protocol.encryption.set = allow_incoming,try_outgoing,enable_retry

          # Limits for file handle resources, this is optimized for
          # an `ulimit` of 1024 (a common default). You MUST leave
          # a ceiling of handles reserved for rTorrent's internal needs!
          network.http.max_open.set = 50
          network.max_open_files.set = 600
          network.max_open_sockets.set = 300

          # Memory resource usage (increase if you have a large number of items loaded,
          # and/or the available resources to spend)
          pieces.memory.max.set = 1800M
          network.xmlrpc.size_limit.set = 4M

          # Basic operational settings (no need to change these)
          session.path.set = (cat, (cfg.session))
          directory.default.set = (cat, (cfg.download))
          log.execute = (cat, (cfg.logs), "execute.log")
          ##log.xmlrpc = (cat, (cfg.logs), "xmlrpc.log")
          execute.nothrow = sh, -c, (cat, "echo >",\
              (session.path), "rtorrent.pid", " ", (system.pid))

          # Other operational settings (check & adapt)
          encoding.add = utf8
          system.umask.set = 0022
          system.cwd.set = (directory.default)
          network.http.dns_cache_timeout.set = 25
          schedule2 = monitor_diskspace, 15, 60, ((close_low_diskspace, 1000M))
          ##pieces.hash.on_completion.set = no
          ##view.sort_current = seeding, greater=d.ratio=
          ##keys.layout.set = qwerty
          ##network.http.capath.set = "/etc/ssl/certs"
          ##network.http.ssl_verify_peer.set = 0
          ##network.http.ssl_verify_host.set = 0

          # Some additional values and commands
          method.insert = system.startup_time, value|const, (system.time)
          method.insert = d.data_path, simple,\
              "if=(d.is_multi_file),\
                  (cat, (d.directory), /),\
                  (cat, (d.directory), /, (d.name))"
          method.insert = d.session_file, simple, "cat=(session.path), (d.hash), .torrent"

          # Watch directories (add more as you like, but use unique schedule names)
          schedule2 = watch_start, 10, 10, ((load.start_verbose, (cat, (cfg.watch), "start/*.torrent")))
          schedule2 = watch_load, 11, 10, ((load.verbose, (cat, (cfg.watch), "load/*.torrent")))

          # Run the rTorrent process as a daemon in the background
          # (and control via XMLRPC sockets)
          #system.daemon.set = true
          network.scgi.open_local = (cat,(session.path),rtorrent.sock)
          execute.nothrow = chmod,777,(cat,(session.path),rtorrent.sock)

          # Logging:
          #   Levels = critical error warn notice info debug
          #   Groups = connection_* dht_* peer_* rpc_* storage_* thread_* tracker_* torrent_*
          print = (cat, "Logging to ", (cfg.logfile))
          log.open_file = "log", (cfg.logfile)
          log.add_output = "info", "log"
          ##log.add_output = "tracker_debug", "log"

          ### END of rtorrent.rc ###
        '';
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
