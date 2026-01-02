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
    };
  };

  # Reminder banner if not logged in (use initContent per HM guidance)
  programs.zsh.initContent = lib.mkAfter ''
    if command -v atuin >/dev/null 2>&1; then
      if ! atuin status 2>/dev/null | grep -q "Logged in"; then
        echo "[atuin] run 'atuin login' to enable sync" >&2
      fi
    fi
  '';
}
