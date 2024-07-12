{ inputs, outputs, config, lib, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix

      inputs.home-manager.nixosModules.home-manager
    ];

  nixpkgs.config.allowUnfree = true;

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };
 
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "nixos-adam"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

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
      inputs.firefox.packages.${system}.firefox-nightly-bin
      firefox

      # work
      python311
      python311Packages.python-hglib
      git-cinnabar
      mozphab
      zoom-us

      # graphics
      aseprite
      blender
      inkscape
      krita

      # gamedev
      godot_4
      love
      tiled
      ldtk
    ];
  };

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    nerdfonts
  ];

  home-manager.extraSpecialArgs = { inherit inputs outputs; };
  home-manager.users.adam = { pkgs, ... }: with pkgs; {
    nixpkgs = {
      config = {
        allowUnfree = true;
        # Workaround for https://github.com/nix-community/home-manager/issues/2942
        allowUnfreePredicate = _: true;
      };
    };

    home.packages = [
      wl-clipboard
      wf-recorder
      grim
      slurp
      lunarvim
    ];

    # terminal config
    programs.kitty = {
      enable = true;
      font.name = "FiraCode Nerd Font Mono";
      theme = "Gruvbox Dark Hard";
      shellIntegration.mode = "no-cursor";
      settings = {
        scrollback_lines = 10000;
        background_opacity = "0.95";
        background_blur = 16;
        cursor_shape = "block";
        cursor_shape_unfocused = "hollow";
        shell = "fish";
      };
    };
    programs.fish = {
      enable = true;
      functions = {
        gitignore = "curl -sL https://www.gitignore.io/api/$argv";
      };
    };
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
            title = "zoom";
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

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget

    home-manager

    # devtools
    git
    clang_18
    cmake
    ninja
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
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
    };
  };

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
