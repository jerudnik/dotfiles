# Atuin shell history configuration
# Config managed by chezmoi (dot_config/atuin/config.toml.tmpl)
# We install the package but don't use programs.atuin to avoid HM generating config files
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Install atuin package only - no programs.atuin.enable
  # This prevents home-manager from generating ~/.config/atuin/config.toml
  home.packages = [ pkgs.atuin ];

  # Shell integration and daemon are handled in zsh.nix initContent
}
