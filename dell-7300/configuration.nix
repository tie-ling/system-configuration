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

  # nix.settings.substituters = [ "https://mirror.sjtu.edu.cn/nix-channels/store" ];
  programs.sway.enable = true;
  programs.sway.extraPackages = with pkgs; [
    foot
    wmenu
    swaylock
    swayidle
    grim
    gnome.adwaita-icon-theme # mouse cursor and icons
    gnome.gnome-themes-extra
    rofi
    dunst # notification daemon
    feh # simple image viewer
    i3status-rust
    wl-clipboard
    xdg-utils # important for links in programs to work
  ];
  # for codium
  programs.sway.extraSessionCommands = ''
    export ELECTRON_OZONE_PLATFORM_HINT=wayland
  '';
  programs.sway.wrapperFeatures.gtk = true;

  networking.hostName = "dell-7300"; # Define your hostname.

  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  services = {
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
  security = {
    doas.enable = true;
    sudo.enable = false;
  };

  fonts.fontconfig = {
    defaultFonts = {
      sansSerif = [
        "DejaVu Sans"
        "Noto Sans CJK SC"
      ];
      monospace = [
        "JuliaMono"
        "DejaVu Sans Mono"
        "Noto Sans Mono CJK SC"
      ];
      serif = [
        "DejaVu Serif"
        "Noto Sans CJK SC"
      ];
    };
  };

  zramSwap.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.initrd.systemd.enable = true;

  programs.git.enable = true;

  # for trash and mtp in thunar
  services.gvfs.enable = true;

  services.davfs2 = {
    enable = true;
  };
  networking = {
    firewall.enable = true;
  };
  users.mutableUsers = false;
  services.upower.enable = true;
  services.emacs = {
    enable = true;
    package = (
      (pkgs.emacsPackagesFor pkgs.emacs29-pgtk).emacsWithPackages (
        epkgs:
        builtins.attrValues {
          inherit (epkgs)
            nix-mode
            magit
            pyim
            pyim-basedict
            company
            ledger-mode
            ;
        }
      )
    );
    defaultEditor = true;
    install = true;
  };

  users.users = {
    yc = {
      initialHashedPassword = "$y$j9T$S0WLvSG97zHExGCytM8L1/$wKCuLpnhARX5.ErsS9dGKpSLeTuHJ9iD3Kb/O5ZGJe4";
      description = "Yuchen Guo";
      packages = with pkgs; [
        gnome.nautilus
        qrencode
        xournalpp
        mpv
        yt-dlp
        chromium
        libreoffice
        kdePackages.okular
        evince
        mupdf
        xfce.mousepad
        brightnessctl
        pavucontrol
        networkmanagerapplet
        xarchiver
        # informatik
        python3
        sqlite
        # end informatik
        # https://plaintextaccounting.org/
        # haskell bookkeeping
        hledger
        hledger-ui
        hledger-web
      ];
      extraGroups = [
        # use doas
        "wheel"
        "networkmanager"
      ];
      isNormalUser = true;
    };
  };
  fonts.packages = builtins.attrValues {
    inherit (pkgs)
      dejavu_fonts
      noto-fonts-cjk-sans
      julia-mono
      font-awesome
      ;
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
  i18n.defaultLocale = "en_US.UTF-8";
  programs.firefox = {
    enable = true;
  };
  hardware.opengl.extraPackages = with pkgs; [ intel-media-driver ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     firefox
  #     tree
  #   ];
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ mg ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
