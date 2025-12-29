# Helix editor configuration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.helix = {
    enable = true;

    # Default editor
    defaultEditor = true;

    # Helix configuration
    # Theme is managed by Stylix (see modules/base/stylix.nix)
    settings = {
      # Editor settings
      editor = {
        # Line numbers
        line-number = "relative";

        # Cursor shape
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        # Scrolloff (lines to keep visible above/below cursor)
        scrolloff = 8;

        # Mouse support
        mouse = true;

        # Middle-click paste
        middle-click-paste = true;

        # Auto-save
        auto-save = {
          focus-lost = true;
          after-delay.enable = true;
          after-delay.timeout = 3000;
        };

        # Auto-format on save
        auto-format = true;

        # Completion
        completion-trigger-len = 1;

        # Idle timeout for showing hints
        idle-timeout = 250;

        # File picker
        file-picker = {
          hidden = false; # Show hidden files
          git-ignore = true;
        };

        # Status line
        statusline = {
          left = [
            "mode"
            "spinner"
            "file-name"
            "file-modification-indicator"
          ];
          center = [ ];
          right = [
            "diagnostics"
            "selections"
            "position"
            "file-encoding"
            "file-line-ending"
            "file-type"
          ];
          separator = "│";
          mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "SELECT";
          };
        };

        # Indent guides
        indent-guides = {
          render = true;
          character = "│";
          skip-levels = 1;
        };

        # Soft wrap
        soft-wrap = {
          enable = true;
        };

        # LSP
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

        # Inline diagnostics
        inline-diagnostics = {
          cursor-line = "warning";
        };
      };

      # Keys
      keys = {
        normal = {
          # Quick save
          C-s = ":w";

          # Window navigation (like vim)
          C-h = "jump_view_left";
          C-j = "jump_view_down";
          C-k = "jump_view_up";
          C-l = "jump_view_right";

          # Buffer navigation
          H = ":buffer-previous";
          L = ":buffer-next";

          # Quick access to file picker
          C-p = "file_picker";

          # Quick access to buffer picker
          C-b = "buffer_picker";

          # Comment toggle (space + /)
          "space" = {
            "/" = "toggle_comments";
            f = "file_picker";
            b = "buffer_picker";
            s = "symbol_picker";
            w = ":w";
            q = ":q";
          };
        };

        insert = {
          # Quick exit insert mode
          j = {
            k = "normal_mode";
          };
        };
      };
    };

    # Language-specific settings
    languages = {
      language-server = {
        # Nix language server
        nil = {
          command = "${pkgs.nil}/bin/nil";
        };

        # Python language server (pinned to python311 to match development.nix)
        pylsp = {
          command = "${pkgs.python311Packages.python-lsp-server}/bin/pylsp";
        };
      };

      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
          language-servers = [ "nil" ];
        }
        {
          name = "python";
          auto-format = true;
          language-servers = [ "pylsp" ];
        }
        {
          name = "rust";
          auto-format = true;
        }
        {
          name = "toml";
          auto-format = true;
        }
        {
          name = "yaml";
          auto-format = true;
        }
        {
          name = "json";
          auto-format = true;
        }
        {
          name = "markdown";
          auto-format = true;
          soft-wrap.enable = true;
        }
      ];
    };
  };

  # Install language servers
  home.packages = with pkgs; [
    # Nix
    nil
    nixfmt-rfc-style

    # Python (pinned to python311 to match development.nix)
    python311Packages.python-lsp-server

    # Rust (rust-analyzer provided by rustup: `rustup component add rust-analyzer`)

    # YAML/JSON
    yaml-language-server
    # Note: vscode-json-languageserver removed to avoid Node.js version conflict
    # Helix has built-in JSON support; re-add if needed with pinned Node version

    # Markdown
    marksman

    # General
    taplo # TOML
  ];
}
