# Git configuration
{
  pkgs,
  ...
}:

{
  # Git configuration is managed by chezmoi (dot_gitconfig.tmpl)
  # Keep GitHub CLI settings here
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      prompt = "enabled";
    };
  };

  # Delta pager still installed via Home Manager
  home.packages = [ pkgs.delta ];
}
