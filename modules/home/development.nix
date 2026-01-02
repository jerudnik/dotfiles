# Development runtimes and tools
# Python, Node.js, Rust environments
{
  config,
  pkgs,
  lib,
  ...
}:
let
  sopsLib = pkgs.writeTextDir "lib/sops.sh" ''
    # direnv layout for SOPS secrets decryption
    # Usage: In your project's .envrc, add: use sops /path/to/secrets.yaml
    use_sops() {
      local secrets_file="''${1:-secrets.yaml}"
      if [[ -f "$secrets_file" ]]; then
        local age_key="''${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/yubikey-identity.txt}"
        if [[ -f "$age_key" ]]; then
          export SOPAGE_KEY_FILE="$age_key"
          eval "$(SOPS_AGE_KEY_FILE="$age_key" sops -d --output-type dotenv "$secrets_file" 2>/dev/null | sed 's/^/export /')"
        fi
      fi
    }
  '';
in
{
  home.packages = with pkgs; [
    python311
    python311Packages.pip
    rustup
    cmake
    gnumake
  ];

  xdg.configFile."direnv/lib/sops.sh".source = "${sopsLib}/lib/sops.sh";

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.sessionVariables = {
    RUSTUP_HOME = "${config.home.homeDirectory}/.rustup";
    CARGO_HOME = "${config.home.homeDirectory}/.cargo";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.cargo/bin"
  ];
}
