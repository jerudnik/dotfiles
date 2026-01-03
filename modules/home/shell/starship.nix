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
      palette = lib.mkForce "stylix";

      palettes.stylix = {
        base00 = "#${config.lib.stylix.colors.base00}";
        base03 = "#${config.lib.stylix.colors.base03}";
        base05 = "#${config.lib.stylix.colors.base05}";
        base07 = "#${config.lib.stylix.colors.base07}";
        accent = "#${config.lib.stylix.colors.base0D}";
        success = "#${config.lib.stylix.colors.base0B}";
        warning = "#${config.lib.stylix.colors.base0A}";
        error = "#${config.lib.stylix.colors.base08}";
        info = "#${config.lib.stylix.colors.base0C}";
        muted = "#${config.lib.stylix.colors.base03}";
      };

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

      directory = {
        style = "fg:accent";
        truncation_length = 4;
        truncate_to_repo = true;
      };

      character = {
        success_symbol = "[❯](fg:success)";
        error_symbol = "[❯](fg:error)";
        vimcmd_symbol = "[❮](fg:info)";
      };

      git_branch = {
        format = "[$branch]($style)";
        style = "fg:muted";
      };

      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)]($style) ($ahead_behind$stashed)]($style)";
        style = "fg:info";
        conflicted = "";
        untracked = "";
        modified = "";
        staged = "";
        renamed = "";
        deleted = "";
        stashed = "≡";
      };

      git_state = {
        format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
        style = "fg:muted";
      };

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "fg:warning";
        min_time = 2000;
      };

      python = {
        format = "[$virtualenv]($style) ";
        style = "fg:muted";
      };

      nix_shell = {
        format = "[$symbol$state]($style) ";
        symbol = " ";
        style = "fg:accent";
        impure_msg = "";
        pure_msg = "";
      };

      username = {
        format = "[$user]($style)@";
        style_user = "fg:muted";
        style_root = "fg:error";
        show_always = false;
      };

      hostname = {
        format = "[$hostname]($style) ";
        style = "fg:muted";
        ssh_only = true;
      };
    };
  };
}
