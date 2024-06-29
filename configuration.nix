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
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # secure boot

  # Lanzaboote currently replaces the systemd-boot module.
  # This setting is usually set to true in configuration.nix
  # generated at installation time. So we force it to false
  # for now.
  boot.loader.systemd-boot.enable = false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.substituters = [ "https://mirror.sjtu.edu.cn/nix-channels/store" ];
  programs.sway.enable = true;
  programs.sway.extraPackages = with pkgs; [
    foot
    wmenu
    swaylock
    swayidle
    i3status
    brightnessctl
    wl-clipboard
    grim
    gnome.adwaita-icon-theme
    gnome.gnome-themes-extra
  ];
  networking.hostName = "yinzhou"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  services = {
    emacs = {
      enable = true;
      package = pkgs.emacs-nox;
      defaultEditor = true;
      install = true;
    };
    tlp = {
      enable = true;
      settings = {
        STOP_CHARGE_THRESH_BAT0 = 1;
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
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
  };
  networking = {
    firewall.enable = true;
  };
  users.mutableUsers = false;
  users.users = {
    yc = {
      initialHashedPassword = "$6$UxT9KYGGV6ik$BhH3Q.2F8x1llZQLUS1Gm4AxU7bmgZUP7pNX6Qt3qrdXUy7ZYByl5RVyKKMp/DuHZgk.RiiEXK8YVH.b2nuOO/";
      description = "Yuchen Guo";
      packages = with pkgs; [
        xournalpp
        mpv
        zathura
        pulseaudio
        proxychains-ng
        (pkgs.pass.withExtensions (exts: [ exts.pass-otp ]))
      ];
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
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
  i18n.defaultLocale = "en_US.UTF-8";
  programs.firefox = {
    enable = true;
    policies = {
      "3rdparty" = {
        Extensions = {
          # name must be the same as above
          "uBlock0@raymondhill.net" = {
            adminSettings = {
              userSettings = {
                advancedUserEnabled = true;
                popupPanelSections = 31;
              };
              dynamicFilteringString = ''
                * * inline-script block
                * * 1p-script block
                * * 3p-script block
                * * 3p-frame block'';
              hostnameSwitchesString = ''
                no-cosmetic-filtering: * true
                no-remote-fonts: * true
                no-csp-reports: * true
                no-scripting: * true
              '';
            };
          };
        };
      };
      # captive portal enabled for connecting to free wifi
      CaptivePortal = false;
      Cookies = {
        Behavior = "reject-tracker-and-partition-foreign";
        BehaviorPrivateBrowsing = "reject-tracker-and-partition-foreign";
      };
      DisableBuiltinPDFViewer = true;
      DisableFirefoxAccounts = true;
      DisableFirefoxStudies = true;
      DisableFormHistory = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisplayMenuBar = "never";
      DNSOverHTTPS = {
        Enabled = false;
      };
      DontCheckDefaultBrowser = true;
      EncryptedMediaExtensions = {
        Enabled = false;
      };
      ExtensionUpdate = false;
      FirefoxHome = {
        SponsoredTopSites = false;
        Pocket = false;
        SponsoredPocket = false;
      };
      HardwareAcceleration = true;
      Homepage = {
        StartPage = "none";
      };
      NetworkPrediction = false;
      NewTabPage = false;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      PasswordManagerEnabled = false;
      PDFjs = {
        Enabled = false;
      };
      Permissions = {
        Location = {
          BlockNewRequests = true;
        };
        Notifications = {
          BlockNewRequests = true;
        };
      };
      PictureInPicture = {
        Enabled = false;
      };
      PopupBlocking = {
        Default = false;
      };
      PromptForDownloadLocation = true;
      SearchSuggestEnabled = false;
      ShowHomeButton = true;
      UserMessaging = {
        WhatsNew = false;
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        MoreFromMozilla = false;
        SkipOnboarding = true;
      };
    };
    preferences = {
      "browser.aboutConfig.showWarning" = false;
      "browser.backspace_action" = 0;
      "browser.chrome.site_icons" = false;
      "browser.display.use_document_fonts" = 0;
      "browser.tabs.firefox-view" = false;
      "browser.tabs.inTitlebar" = 0;
      "browser.uidensity" = 1;
      "general.smoothScroll" = false;
      "gfx.font_rendering.opentype_svg.enabled" = false;
      "media.ffmpeg.vaapi.enabled" = true;
      "media.navigator.mediadatadecoder_vpx_enabled" = true;
      "network.IDN_show_punycode" = true;
      "dom.security.https_only_mode" = true;
      "widget.wayland.opaque-region.enabled" = false;
    };
    preferencesStatus = "default";
    autoConfig = ''
      pref("apz.allow_double_tap_zooming", false);
      pref("apz.allow_zooming", false);
      pref("apz.gtk.touchpad_pinch.enabled", false);
      pref("webgl.disable-extensions", true);
      pref("webgl.disable-fail-if-major-performance-caveat", true);
      pref("webgl.disabled", true);
      pref("webgl.min_capability_mode", true);
      pref("javascript.enabled", false);
      pref("javascript.options.asmjs", false);
      pref("javascript.options.wasm", false);
      pref("javascript.options.ion", false);
      pref("javascript.options.baselinejit", false);
      pref("font.name-list.emoji", "Noto Color Emoji");
    '';
  };

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
  environment.systemPackages = with pkgs; [
    mg
    # create secure boot keys
    sbctl
    powertop
  ];

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
