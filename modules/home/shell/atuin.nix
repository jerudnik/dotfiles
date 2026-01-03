{ config, lib, ... }:
{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    daemon.enable = true;
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "fuzzy";
      style = "compact";
      inline_height = 20;
      show_preview = true;
      username = "jrudnik";
      email = "john.rudnik@gmail.com";
      # sops-nix writes to /run/secrets/atuin/key on both darwin+nixos
      key_path = "/run/secrets/atuin/key";
    };
  };
}
