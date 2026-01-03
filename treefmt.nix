{ pkgs }:
{
  projectRootFile = "flake.nix";

  programs.nixfmt = {
    enable = true;
    package = pkgs.nixfmt-rfc-style;
  };

  programs.prettier = {
    enable = true;
    package = pkgs.nodePackages.prettier;
    includes = [ "*.md" "*.yaml" "*.yml" "*.json" ];
  };
}
