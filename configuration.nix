# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
in {
  imports =
    [
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];
    
  nixpkgs.overlays = [
    moz_overlay
  ];
 
  # Needed for firefox-nightly-bin
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "nixos-adam"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
  };

  programs.light.enable = true;

  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  services.libinput.enable = true;

  users.users.adam = {
    isNormalUser = true;
    extraGroups = [ "wheel" "disk" "libvirtd" "docker" "audio" "networkmanager" "video" "input" "network" "systemd-journal" ];
    packages = with pkgs; [
      latest.firefox-nightly-bin
      python311
      python311Packages.python-hglib
      git-cinnabar
      mozphab
    ];
  };

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    nerdfonts
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.users.adam = { pkgs, ... }: with pkgs; {
    home.packages = [
      wl-clipboard
      wf-recorder
      grim
      slurp
    ];

    # terminal config
    programs.kitty = {
      enable = true;
      font.name = "FiraCode Nerd Font Mono";
      theme = "Gruvbox Dark Hard";
      settings = {
        scrollback_lines = 10000;
        background_opacity = "0.8";
        background_blur = 16;
      };
    };
    programs.fish.enable = true;
    programs.btop.enable = true;
    programs.bat.enable = true;
    programs.fd.enable = true;
    programs.fzf.enable = true;
    programs.ripgrep.enable = true;
    programs.zoxide.enable = true;
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };
    programs.nix-index.enable = true;
    programs.starship.enable = true;
    programs.lsd = {
      enable = true;
      enableAliases = true;
    };

    fonts.fontconfig.enable = true;

    # sway config
    programs.fuzzel = {
      enable = true;
      settings.main.terminal = "kitty";
    };
    programs.swaylock.enable = true;
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings = { mainBar = import ./waybar-config.nix; };
      style = ./waybar-style.css;
    };
    services.swayidle.enable = true;
    services.mako.enable = true;
    services.gammastep = {
      enable = true;
      tray = true;
      dawnTime = "6:00-7:00";
      duskTime = "19:00-20:30";
    };
    services.network-manager-applet.enable = true;
    services.blueman-applet.enable = true;
    wayland.windowManager.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      swaynag.enable = true;

      checkConfig = false; # needed because of https://www.reddit.com/r/NixOS/comments/1c9n1qk/comment/l0n4u6y/
                           # tl;dr: home trys to find the bg file at build time, can't, and throws an error
      config = {
        modifier = "Mod4";

        bars = [];

        gaps = {
          inner = 5;
          smartBorders = "on";
          smartGaps = true;
        };

        terminal = "kitty";

        output = {
          "*" = { bg = "~/Tilting-at-Windmills.png fill"; };
          DP-1 = { adaptive_sync = "on"; };
          DP-3 = { scale = "1.5"; };
        };

        floating.criteria = [
          {
            title = "Steam - Update News";
          }
          {
            title = "Picture-in-Picture";
          }
          {
            class = "Pavucontrol";
          }
        ];

        startup = [
          { command = "systemctl --user restart waybar"; always = true; }
        ];
        menu = "fuzzel";
      };
    };

    programs.vscode = {
      enable = true;
      package = vscodium;
      mutableExtensionsDir = false;
      extensions = [
        vscode-extensions.asvetliakov.vscode-neovim
        vscode-extensions.llvm-vs-code-extensions.vscode-clangd
        vscode-extensions.rust-lang.rust-analyzer
        vscode-extensions.esbenp.prettier-vscode
      ];
    };

    home.stateVersion = "24.05";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    git
    clang_18
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.steam.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

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
