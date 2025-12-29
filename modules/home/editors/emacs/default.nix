{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.myEmacs;
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  options.programs.myEmacs = {
    enable = mkEnableOption "Emacs configuration";

    orgDirectory = mkOption {
      type = types.str;
      default = "~/Notes/org";
      description = "Directory for org-mode files";
    };
  };

  config = mkIf cfg.enable {
    # On Linux, use programs.emacs with Nix packages
    # On macOS, Emacs is installed via Homebrew (see modules/darwin/homebrew.nix)
    programs.emacs = mkIf isLinux {
      enable = true;
      package = pkgs.emacs30-pgtk;
    };

    # Manage config files (cross-platform)
    xdg.configFile = {
      "emacs/early-init.el".source = ./config/early-init.el;
      "emacs/init.el".source = ./config/init.el;
      "emacs/modules/defaults.el".source = ./config/modules/defaults.el;
      "emacs/modules/keybindings.el".source = ./config/modules/keybindings.el;
      "emacs/modules/completion.el".source = ./config/modules/completion.el;
      "emacs/modules/org-config.el".source = ./config/modules/org-config.el;
    };

    # Ensure Homebrew bin is in PATH on macOS
    home.sessionPath = mkIf isDarwin [ "/opt/homebrew/bin" ];

    # Ensure org directory exists
    home.activation.createOrgDirectory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${cfg.orgDirectory}"
    '';

    # LSP servers and tools (used by Emacs via exec-path-from-shell)
    home.packages = with pkgs; [
      # Language servers
      nil # Nix LSP
      nixfmt-rfc-style # Nix formatting
      marksman # Markdown LSP

      # Tools for Emacs packages
      ripgrep # for consult-ripgrep
      fd # for file finding
    ];
  };
}
