# Starship prompt configuration
# Using the Pure preset as base with some customizations
{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    # Pure-inspired configuration
    # https://starship.rs/presets/pure-preset.html
    settings = {
      # Use a custom format similar to Pure
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_state"
        "$git_status"
        "$cmd_duration"
        "$line_break"
        "$python"
        "$nix_shell"
        "$character"
      ];

      # Directory
      directory = {
        style = "blue";
        truncation_length = 4;
        truncate_to_repo = true;
      };

      # Character (prompt symbol)
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](green)";
      };

      # Git branch
      git_branch = {
        format = "[$branch]($style)";
        style = "bright-black";
      };

      # Git status
      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
        style = "cyan";
        conflicted = "";
        untracked = "";
        modified = "";
        staged = "";
        renamed = "";
        deleted = "";
        stashed = "≡";
      };

      # Git state (rebase, merge, etc.)
      git_state = {
        format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
        style = "bright-black";
      };

      # Command duration
      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
        min_time = 2000; # Show if command takes > 2 seconds
      };

      # Python virtualenv
      python = {
        format = "[$virtualenv]($style) ";
        style = "bright-black";
      };

      # Nix shell indicator
      nix_shell = {
        format = "[$symbol$state]($style) ";
        symbol = " ";
        style = "blue";
        impure_msg = "";
        pure_msg = "";
      };

      # Username (only show if not default user or on SSH)
      username = {
        format = "[$user]($style)@";
        style_user = "bright-black";
        style_root = "red";
        show_always = false;
      };

      # Hostname (only show on SSH)
      hostname = {
        format = "[$hostname]($style) ";
        style = "bright-black";
        ssh_only = true;
      };
    };
  };
}
