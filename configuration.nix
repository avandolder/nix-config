{
  inputs,
  outputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix

    inputs.home-manager.nixosModules.home-manager
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;

  nixpkgs.overlays = [
    inputs.fenix.overlays.default

    # (final: prev: {
    #   clang-tools_18 = prev.clang-tools_18.overrideAttrs (oldAttrs: {
    #     name = "clang-tools_18-patched";
    #     patches = (oldAttrs.patches or []) ++ [(final.fetchpatch {
    #       name = "fix-clangd-BlockEnd-hint.patch";
    #       url = "https://github.com/llvm/llvm-project/pull/72345.patch";
    #       sha256 = "sha256-Al59zOQux52QOwa5M+1MC0uTFRtNUtEGg11NU7u3/dY=";
    #     })];
    #   });
    # })
  ];

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
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
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

      # Configure nix GC
      settings.auto-optimise-store = true;
      gc.dates = "weekly";
      gc.automatic = true;
      gc.options = "--delete-older-than 7d";
    };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
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
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
  };
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];

  programs.light.enable = true;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

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
    extraGroups = [
      "wheel"
      "disk"
      "libvirtd"
      "docker"
      "audio"
      "networkmanager"
      "video"
      "input"
      "network"
      "systemd-journal"
    ];
    packages = with pkgs; [
      inputs.firefox.packages.${system}.firefox-nightly-bin
      firefox
      ungoogled-chromium

      # work
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

      # games
      lutris
    ];
  };

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    nerdfonts
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
  };
  home-manager.backupFileExtension = "backup";
  home-manager.users.adam = import ./home-manager/home.nix;

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  environment.systemPackages = with pkgs; [
    home-manager

    git
    git-lfs
    gh
    mercurial
    subversion
    curl
    wget
    p7zip

    python3
    zig

    # c++ stuff
    clang_18
    clang-tools_18
    cmake
    meson
    xmake
    scons
    build2
    ninja

    # common libs
    mesa
    glfw
    freeglut

    # rust stuff
    inputs.fenix.packages.x86_64-linux.complete.toolchain

    # let's try medium for now
    texliveMedium
  ];

  environment.sessionVariables = { };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    #gamescopeSession.enable = true;
  };
  programs.gamescope.enable = true;
  programs.nix-ld.enable = true;

  # need this for hyprland via home-manager
  programs.hyprland.enable = true;
  security.pam.services.hyprlock = { };

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
