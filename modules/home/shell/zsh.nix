# Zsh configuration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.zsh = {
    enable = true;

    # Enable completions
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # History settings
    history = {
      size = 50000;
      save = 50000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      share = true; # Share history between sessions
    };

    # Session variables
    sessionVariables = {
      PAGER = "less";
      LESS = "-R";
      # Secretive SSH agent socket (macOS Secure Enclave)
      # Uses ~/Library which expands correctly per-user
      SSH_AUTH_SOCK = "${config.home.homeDirectory}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
    };

    # Shell aliases are now managed by chezmoi in ~/.config/zsh/aliases.zsh
    shellAliases = { };

    # Additional initialization
    initContent = ''
      # Source chezmoi-managed zsh configs
      [[ -f ~/.config/zsh/aliases.zsh ]] && source ~/.config/zsh/aliases.zsh
      [[ -f ~/.config/zsh/functions.zsh ]] && source ~/.config/zsh/functions.zsh
      [[ -f ~/.config/zsh/local.zsh ]] && source ~/.config/zsh/local.zsh

      # Initialize starship prompt
      eval "$(starship init zsh)"

      # Initialize atuin (shell history)
      # Start daemon if not running, then init shell integration
      if command -v atuin &> /dev/null; then
        export ATUIN_LOG=error
        if ! pgrep -x "atuin" > /dev/null 2>&1; then
          atuin daemon &> /dev/null &
          disown
        fi
        eval "$(atuin init zsh --disable-up-arrow)"
      fi

      # Initialize zoxide (smarter cd)
      eval "$(zoxide init zsh)"

      # FZF configuration
      export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"
      export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"

      # Better history search with fzf
      bindkey '^R' history-incremental-search-backward

      # Ghostty shell integration (after other plugins)
      if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
        source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
      fi
    '';

    # Plugins (using home-manager's plugin system)
    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "v1.1.2";
          sha256 = "sha256-Qv8zAiMtrr67CbLRrFjGaPzFZcOiMVEFLg1Z+N6VMhg=";
        };
      }
      {
        name = "you-should-use";
        src = pkgs.zsh-you-should-use;
        file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
      }
    ];
  };

  # FZF integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
