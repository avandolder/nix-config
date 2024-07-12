{
  pkgs,
  ...
}: {
    nixpkgs = {
      config = {
        allowUnfree = true;
        # Workaround for https://github.com/nix-community/home-manager/issues/2942
        allowUnfreePredicate = _: true;
      };
    };

    home.packages = with pkgs; [
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
      package = pkgs.vscodium;
      mutableExtensionsDir = false;
      extensions = [
        pkgs.vscode-extensions.asvetliakov.vscode-neovim
        pkgs.vscode-extensions.llvm-vs-code-extensions.vscode-clangd
        pkgs.vscode-extensions.rust-lang.rust-analyzer
        pkgs.vscode-extensions.esbenp.prettier-vscode
      ];
    };

    home.stateVersion = "24.05";
}
