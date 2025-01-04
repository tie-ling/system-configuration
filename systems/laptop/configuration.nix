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

let
  mytex = pkgs.texliveConTeXt.withPackages (
    ps: with ps; [
      fandol
      context-simpleslides
      context-notes-zh-cn
    ]
  );
  mypy = pkgs.python3.withPackages (
    python-pkgs: with python-pkgs; [
      notmuch
      pygit2
    ]
  );
  mychromium = pkgs.ungoogled-chromium.override {
    commandLineArgs = [
      "--disable-webgl"
      # privacy features
      # https://github.com/ungoogled-software/ungoogled-chromium/blob/master/docs/flags.md
      "--enable-features=NoReferrers,ReducedSystemInfo,ClearDataOnExit"
      "--disable-remote-fonts"
      "--ozone-platform=wayland"
      "--enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,VaapiIgnoreDriverChecks,VaapiVideoDecoder,PlatformHEVCDecoderSupport,UseMultiPlaneFormatForHardwareVideo"
      "--ignore-gpu-blocklist"
    ];
  };

  mypass = pkgs.pass-wayland.withExtensions (
    exts: with exts; [
      pass-otp
      pass-import
      pass-genphrase
    ]
  );
in
{

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/hardened.nix")
  ];

  # bootloader
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.initrd.systemd.enable = true;
  zramSwap.enable = true;
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.initrd.availableKernelModules = [
    "ahci"
    "nvme"
    "xhci_pci"
    "rtsx_pci_sdmmc"
    "thunderbolt"
    "uas"
    "sd_mod"
    "sdhci_pci"
  ];
  system.stateVersion = "24.05"; # Did you read the comment?

  # security; remember to enable hardened mode
  security.lockKernelModules = false;
  security = {
    doas.enable = true;
    sudo.enable = false;
  };
  security.chromiumSuidSandbox.enable = true;
  services.logrotate.checkConfig = false;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # nix related
  # nix.settings.substituters = [ "https://mirror.sjtu.edu.cn/nix-channels/store" ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  programs.git.enable = true;
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  programs.bash.shellInit = ''
    nixosbuildsw () {
      local name=$1 
      chown -R root /home/yc/sys-conf
      nixos-rebuild switch --flake /home/yc/sys-conf#$name
      chown -R  yc /home/yc/sys-conf
    }
    nixosbuildbo () {
      local name=$1
      chown -R root /home/yc/sys-conf
      nixos-rebuild boot --flake /home/yc/sys-conf#$name
      chown -R  yc /home/yc/sys-conf
    }
  '';

  # desktop fonts
  fonts.fontconfig = {
    defaultFonts = {
      sansSerif = [
        "DejaVu Sans"
        "Noto Sans CJK SC"
      ];
      monospace = [
        "JuliaMono"
        "Noto Sans Mono CJK SC"
      ];
      serif = [
        "DejaVu Serif"
        "Noto Serif CJK SC"
      ];
    };
  };
  fonts.packages = builtins.attrValues {
    inherit (pkgs)
      dejavu_fonts
      babelstone-han
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      julia-mono
      font-awesome
      libertinus
      ;
  };
  fonts.fontconfig.localConf = ''
    <?xml version='1.0'?>
    <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
    <fontconfig>
     <dir>${mytex}/share/texmf/fonts</dir>
    </fontconfig>
  '';
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  # desktop programs
  programs.sway.enable = true;
  programs.sway.extraSessionCommands = ''
    export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
    # Fix for some Java AWT applications (e.g. Android Studio),
    # use this if they aren't displayed properly:
    export _JAVA_AWT_WM_NONREPARENTING=1

    export ELECTRON_OZONE_PLATFORM_HINT=wayland
    export QT_QPA_PLATFORM=wayland
  '';
  programs.sway.extraPackages = with pkgs; [
    foot
    swaylock
    swayidle
    grim
    adwaita-icon-theme # mouse cursor and icons
    gnome-themes-extra
    rofi-wayland
    dunst # notification daemon
    imv # simple image viewer
    i3status-rust
    wl-gammarelay-rs
    wl-clipboard
    xdg-utils
    # not directly related to sway; but needed for a sane desktop experience
    w3m
    mc

  ];

  # desktop internet browser with vaapi
  programs.chromium = {
    enable = true;
    extensions = [
      "ddkjiahejlhfcafbddmgiahcphecmpfh" # ublock origin lite
      "omkfmpieigblcllmkgbflkikinpkodlk" # enhanced h264ify
      "klfoddkbhleoaabpmiigbmpbjfljimgb" # browserpass
    ];
    extraOpts = {
      "PasswordManagerEnabled" = false;
    };
  };
  programs.browserpass.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
  ];

  # networking
  networking.hostId = "4e98920d"; # for zfs pool
  networking.useDHCP = lib.mkDefault true;
  services.dnscrypt-proxy2 = {
    enable = true;
    upstreamDefaults = true;
    settings = {
      ipv6_servers = true;
    };
  };
  # disable built-in dns
  services.resolved.fallbackDns = [ ];
  networking = {
    firewall.enable = true;
  };
  networking = {
    useNetworkd = true;
    wireless.secretsFile = ../../resources/wifi-pass.txt;
    wireless.enable = true;

    # To connect to ad-hoc networks, enable userControlled option.
    # Run $(BROWSER=w3m nixos-help) to read how to connect to wifi
    # using wpa_cli; search for phrase 'Networking in the installer'
    wireless.userControlled.enable = true;
    wireless.networks = {
      # secretsFile must use .pskRaw; generate with wpa_passphrase
      # wpa_passphrase SSID PASS command.
      "FRITZ!Box 7520 UK".pskRaw = "ext:psk_home";
      "BVG Wi-Fi" = { };
      # https://events.ccc.de/congress/2018/wiki/index.php/Static:Network/802.1X_client_settings
      # https://doku.tid.dfn.de/de:eduroam:easyroam#installation_der_easyroam_profile_auf_linux_geraeten
      # man 5 wpa_supplicant.conf
      # do not use double quotes around ext passwords
      eduroam.auth = ''
        key_mgmt=WPA-EAP
        pairwise=CCMP
        group=CCMP
        eap=TLS
        identity="7896401122018379966@easyroam-pca.htw-berlin.de"
        altsubject_match="DNS:easyroam.eduroam.de"
        ca_cert="/etc/ssl/certs/ca-certificates.crt"
        client_cert="/home/yc/Documents/eduroam/easyroam_client_cert.pem"
        private_key="/home/yc/Documents/eduroam/easyroam_client_key.pem"
        private_key_passwd="qhyzcqys"
      '';
    };
  };
  networking.nameservers = [ "127.0.0.1" ];

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # services
  services.zfs.autoSnapshot.enable = config.boot.supportedFilesystems.zfs;
  services.openvpn = {
    servers = {
      client-htw = {
        # https://rz.htw-berlin.de/anleitungen/vpn/linux/
        autoStart = false;
        config = ''
          dev tun
          config ${../../resources/vpn-htw-berlin.ovpn}'';
      };
    };
  };
  services = {
    openssh = {
      # used to transfer files between my laptops
      enable = true;
      settings = {
        PasswordAuthentication = false;
      };
      allowSFTP = true;
      openFirewall = true;
    };
    tlp = {
      enable = true;
      settings = {
        STOP_CHARGE_THRESH_BAT0 = 1;
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
  services.upower.enable = true;
  services.emacs = {
    enable = true;
    package = (
      (pkgs.emacsPackagesFor pkgs.emacs-nox).emacsWithPackages (
        epkgs:
        builtins.attrValues {
          inherit (epkgs)
            # git porcelain
            magit
            # pinyin
            pyim
            pyim-basedict
            # auto complete
            counsel
            # accounting
            ledger-mode
            # emails
            notmuch
            # nix; haskell; context
            nix-mode
            haskell-mode
            ;
          inherit (epkgs.treesit-grammars) with-all-grammars;
        }
      )
    );
    defaultEditor = true;
    install = true;
  };

  # users
  # nix path-info -rS /run/current-system | sort -nk2
  users.mutableUsers = false;
  users.users = {
    yc = {
      initialHashedPassword = "$y$j9T$S0WLvSG97zHExGCytM8L1/$wKCuLpnhARX5.ErsS9dGKpSLeTuHJ9iD3Kb/O5ZGJe4";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAwcU205j7zIq6IfbJ14G3FcKaIs979qC8NPyxVFhd71 yc@dell-7300"
      ];
      description = "Yuchen Guo";
      packages = builtins.attrValues {
        inherit (pkgs)
          # blog
          hugo
          captive-browser
          qrencode
          xournalpp
          mpv
          yt-dlp
          zathura
          qpdf
          pavucontrol
          _7zz
          # tts and its processing
          ffmpeg
          opusTools
          espeak-ng
          # emails
          notmuch
          isync
          jmtpfs
          ;
        inherit
          mytex
          mypy
          mychromium
          mypass
          ;
        inherit (pkgs.haskellPackages)
          # haskell
          # https://nixos.org/manual/nixpkgs/unstable/#haskell-development-environments
          # https://haskell4nix.readthedocs.io/nixpkgs-users-guide.html#how-to-create-a-development-environment
          # https://haskell-language-server.readthedocs.io/en/latest/configuration.html#emacs
          ghc
          cabal-install
          hledger_1_40
          pandoc-cli
          ;
      };
      extraGroups = [
        # use doas
        "wheel"
      ];
      isNormalUser = true;
    };
  };

  # email; auth related programs
  programs.gnupg = {
    agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-qt;
    };
  };
  programs.ssh.startAgent = true;
  programs.msmtp = {
    enable = true;
    defaults = {
      # Set default values: use the mail submission port 587, and always use TLS.
      # On this port, TLS is activated via STARTTLS.
      auth = true;
      tls = true;
      port = 587;
      tls_starttls = true;
    };
    accounts = {
      Personal = {
        host = "smtp.gmail.com";
        from = "gyuchen86@gmail.com";
        user = "gyuchen86@gmail.com";
        passwordeval = "cat /etc/pass-gmail";
      };
    };
    extraConfig = "account default : Personal";
    setSendmail = true;
  };
}
