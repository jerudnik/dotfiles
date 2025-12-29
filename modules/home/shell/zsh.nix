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
      EDITOR = "hx";
      VISUAL = "hx";
      PAGER = "less";
      LESS = "-R";
    };

    # Shell aliases
    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # ls replacements (using eza)
      ls = "eza";
      l = "eza -la";
      ll = "eza -la";
      la = "eza -la";
      lt = "eza --tree --level=2";
      lta = "eza --tree --level=2 -a";

      # Cat replacement (using bat)
      cat = "bat";

      # Grep replacement (using ripgrep)
      grep = "rg";

      # Find replacement (using fd)
      find = "fd";

      # Nix shortcuts
      rebuild = "sudo darwin-rebuild switch --flake ~/Projects/dotfiles";
      nix-clean = "nix-collect-garbage -d";
      nix-update = "nix flake update ~/Projects/dotfiles";

      # Git shortcuts (in addition to git aliases)
      g = "git";
      gs = "git status -sb";
      ga = "git add";
      gaa = "git add -A";
      gc = "git commit";
      gp = "git push";
      gpl = "git pull";
      gd = "git diff";
      gco = "git checkout";
      gb = "git branch";
      glog = "git log --oneline -20";

      # Directory shortcuts
      dotfiles = "cd ~/Projects/dotfiles";
      projects = "cd ~/Projects";

      # Safety nets
      rm = "rm -i";
      mv = "mv -i";
      cp = "cp -i";

      # Misc
      c = "clear";
      h = "history";
      path = "echo $PATH | tr ':' '\\n'";
      week = "date +%V";
      myip = "curl -s https://ifconfig.me";
    };

    # Additional initialization
    initContent = ''
      # Initialize zoxide (smarter cd)
      eval "$(zoxide init zsh)"

      # FZF configuration
      export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"
      export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"

      # Better history search with fzf
      bindkey '^R' history-incremental-search-backward

      # Useful functions
      mkcd() {
        mkdir -p "$1" && cd "$1"
      }

      # Extract any archive
      extract() {
        if [ -f "$1" ]; then
          case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
          esac
        else
          echo "'$1' is not a valid file"
        fi
      }

      # Quick edit config files
      erc() { $EDITOR ~/dotfiles/users/john/home.nix }
      ezsh() { $EDITOR ~/dotfiles/modules/home/shell/zsh.nix }
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
    ];
  };

  # FZF integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
