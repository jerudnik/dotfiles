# Shared shell aliases
# This file is sourced by all shells (zsh, bash, fish) for consistency
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Emacs aliases (works with daemon)
  home.shellAliases = {
    # Emacs client shortcuts
    e = "emacsclient -c"; # Open new GUI frame
    et = "emacsclient -t"; # Open in terminal
    em = "emacsclient -n"; # Open in existing frame, don't wait

    # Quick org access
    org = "emacsclient -c ~/Notes/org/";
  };
}
