{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  home.packages = with pkgs; [
    wl-clipboard
    wf-recorder
    grim
    slurp
    wdisplays

    lunarvim

    # needed for waybar icons
    font-awesome
  ];

  home.sessionVariables = {
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    XDG_SESSION_TYPE = "wayland";
    WLR_NO_HARDWARE_CURSORS = "1";
    ENABLE_VKBASALT = "1";
    NIXOS_OZONE_WL = "1";
  };

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    colorschemes.gruvbox.enable = true;

    plugins = {
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-e>" = "cmp.mapping.close()";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          };
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
        };
      };
      comment.enable = true;
      crates-nvim.enable = true;
      gitsigns.enable = true;
      hmts.enable = true;
      indent-blankline.enable = true;
      lualine = {
        enable = true;
        extensions = [ "fzf" ];
      };
      lsp = {
        enable = true;
        servers = {
          clangd.enable = true;
          cmake.enable = true;
          denols.enable = true;
          fsautocomplete.enable = true;
          gdscript.enable = true;
          hls.enable = true;
          html.enable = true;
          jsonls.enable = true;
          kotlin-language-server.enable = true;
          lua-ls.enable = true;
          marksman.enable = true;
          metals.enable = true;
          nil-ls.enable = true;
          ocamllsp.enable = true;
          omnisharp.enable = true;
          ruby-lsp.enable = true;
          ruff.enable = true;
          rust-analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
          sourcekit = {
            enable = true;
            # sourcekit is for both Swift and C/C++/ObjC, but I already have
            # normal clangd for C/C++.
            autostart = false;
          };
          sqls.enable = true;
          taplo.enable = true;
          texlab.enable = true;
          yamlls.enable = true;
          zls.enable = true;
        };
      };
      lsp-lines.enable = true;
      nix.enable = true;
      #qmk.enable = true;
      rainbow-delimiters.enable = true;
      telescope.enable = true;
      todo-comments = {
        enable = true;
        ripgrepPackage = null;
      };
      treesitter = {
        enable = true;
        nixvimInjections = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };
      treesitter-context = {
        enable = true;
        settings = {
          line_numbers = true;
          max_lines = 2;
        };
      };
      trim.enable = true;
    };

    opts = {
      number = true;
      relativenumber = true;

      swapfile = false;
      modeline = false;
      undofile = true;

      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      softtabstop = 2;
      smarttab = true;
      autoindent = true;

      incsearch = true;
      ignorecase = true;
      smartcase = true;

      mouse = "a";

      termguicolors = true;
    };

    extraConfigLua = ''
      vim.diagnostic.config({
        virtual_lines = { only_current_line = true },
        virtual_text = false,
      })
    '';
  };

  programs.git = {
    enable = true;
    package = pkgs.git;

    lfs.enable = true;

    userName = "Adam van Dolder";
    userEmail = "adam.vandolder@gmail.com";

    aliases = {
      ci = "commit";
      co = "checkout";
      s = "status";
    };

    extraConfig = {
      credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-launcher";
    };

    ignores = [
      "*~"
      "*.swp"
      ".mozbuild"
    ];
  };

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
      g = "git $argv";
    };
  };
  programs.bottom = {
    enable = true;
    settings = {
      flags = {
        regex = true;
        color = "gruvbox";
        tree = true;
        enable_gpu = true;
        enable_cache_memory = true;
      };
    };
  };
  programs.bat.enable = true;
  programs.fd.enable = true;
  programs.fzf.enable = true;
  programs.ripgrep.enable = true;
  programs.zoxide.enable = true;
  programs.nix-index.enable = true;
  programs.lsd = {
    enable = true;
    enableAliases = true;
  };
  programs.fastfetch.enable = true;

  fonts.fontconfig.enable = true;

  # sway config
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "kitty";
        font = "FiraCode Nerd Font Mono";
        list-executables-in-path = "yes";
      };
    };
  };
  programs.swaylock.enable = true;
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    # config is based off of the Fedora Sway spin
    settings = {
      mainBar = import ./waybar-config.nix;
    };
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

    # needed because of https://www.reddit.com/r/NixOS/comments/1c9n1qk/comment/l0n4u6y/
    # tl;dr: home trys to find the bg file at build time, can't, and throws an error
    checkConfig = false;

    config = {
      modifier = "Mod4";

      keybindings = lib.mkOptionDefault {
        XF86AudioRaiseVolume = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        XF86AudioLowerVolume = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        XF86AudioMute = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };

      bars = [ ];

      gaps = {
        inner = 5;
        smartBorders = "on";
        smartGaps = true;
      };

      terminal = "kitty";

      output = {
        "*" = {
          bg = "~/Tilting-at-Windmills.png fill";
        };
        DP-1 = {
          adaptive_sync = "on";
        };
        DP-3 = {
          scale = "1.5";
        };
      };

      floating.criteria = [
        { title = "Steam - Update News"; }
        { title = "Picture-in-Picture"; }
        { title = "zoom"; }
        { class = "Pavucontrol"; }
      ];

      startup = [
        {
          command = "systemctl --user restart waybar";
          always = true;
        }
      ];
      menu = "fuzzel";
    };
  };

  home.stateVersion = "24.05";
}
