# Git configuration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.git = {
    enable = true;

    # Disable version check warning (using stable nixpkgs with unstable HM)
    # (This is set at home level, see users/john/home.nix)

    # SSH commit signing with secretive (Secure Enclave)
    # Key stored in Secure Enclave, accessed via Touch ID
    # Uses ~/.ssh/secretive.pub symlink (user creates this pointing to their key)
    signing = {
      key = "~/.ssh/secretive.pub";
      signByDefault = true;
    };

    # Git settings (new format for home-manager)
    settings = {
      # User identity
      user = {
        name = "john rudnik";
        email = "john.rudnik@gmail.com";
      };

      # SSH signing configuration (secretive - Secure Enclave)
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";

      # Default branch name
      init.defaultBranch = "main";

      # GitHub username
      github.user = "jerudnik";

      # Credentials
      credential.helper = "osxkeychain";

      # Push behavior
      push = {
        default = "current";
        autoSetupRemote = true;
      };

      # Pull behavior
      pull.rebase = true;

      # Merge behavior
      merge.conflictstyle = "diff3";

      # Diff behavior
      diff.colorMoved = "default";

      # Rebase settings
      rebase = {
        autoStash = true;
        autoSquash = true;
      };

      # Better diff viewer (delta)
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
      };

      # URL shortcuts
      url = {
        "git@github.com:" = {
          insteadOf = "gh:";
        };
        "https://github.com/" = {
          insteadOf = "github:";
        };
      };

      # Aliases
      alias = {
        # Status shortcuts
        s = "status -sb";
        st = "status";

        # Commit shortcuts
        c = "commit";
        cm = "commit -m";
        ca = "commit --amend";
        can = "commit --amend --no-edit";

        # Branch shortcuts
        b = "branch";
        bd = "branch -d";
        bD = "branch -D";
        co = "checkout";
        cob = "checkout -b";
        sw = "switch";
        swc = "switch -c";

        # Diff shortcuts
        d = "diff";
        ds = "diff --staged";

        # Log shortcuts
        l = "log --oneline -20";
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        ll = "log --stat";

        # Stash shortcuts
        sl = "stash list";
        sp = "stash pop";
        ss = "stash save";

        # Reset shortcuts
        unstage = "reset HEAD --";
        undo = "reset --soft HEAD~1";

        # Remote shortcuts
        p = "push";
        pf = "push --force-with-lease";
        pl = "pull";
        f = "fetch";
        fa = "fetch --all";

        # Utility
        aliases = "config --get-regexp ^alias\\.";
        whoami = "config user.email";
      };
    };

    # Global ignore patterns
    ignores = [
      # macOS
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      "._*"
      ".Spotlight-V100"
      ".Trashes"

      # Editors
      "*.swp"
      "*.swo"
      "*~"
      ".idea/"
      ".vscode/"
      "*.sublime-*"

      # Nix
      "result"
      "result-*"

      # Environment
      ".env"
      ".env.local"
      ".envrc"
      ".direnv/"

      # Python
      "__pycache__/"
      "*.py[cod]"
      ".venv/"
      "venv/"
    ];
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };
}
