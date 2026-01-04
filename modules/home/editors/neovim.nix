{ pkgs, ... }:
{
  home.packages = with pkgs; [
    neovim

    nil
    nixfmt-rfc-style
    lua-language-server
    marksman
    yaml-language-server
    taplo
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
