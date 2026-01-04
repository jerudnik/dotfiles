# Starship prompt configuration
# Config managed by chezmoi (dot_config/starship.toml.tmpl)
# We install the package but don't use programs.starship to avoid HM generating config files
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Install starship package only - no programs.starship.enable
  # This prevents home-manager from generating ~/.config/starship.toml
  home.packages = [ pkgs.starship ];

  # Shell integration is added in zsh.nix initContent
}
