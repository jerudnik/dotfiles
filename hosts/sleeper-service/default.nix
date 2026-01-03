# Host configuration for sleeper-service (Google Pixelbook 2017)
# A Culture ship that appears retired but is secretly one of the most capable
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    # Hardware-specific optimizations for Google Pixelbook (EVE)
    inputs.nixos-hardware.nixosModules.google-pixelbook

    # Shared NixOS configuration
    ../common/nixos

    # NixOS-specific modules
    ../../modules/nixos

    # Machine-specific hardware configuration (gitignored)
    ./hardware-configuration.nix
  ];

  # ==========================================================================
  # Intel GPU Workaround
  # ==========================================================================
  # Disable OpenCL compute runtime - intel-compute-runtime-legacy1 fails to
  # build with current nixpkgs (CMake 4.0 incompatibility).
  # Video acceleration (VAAPI) still works without this.
  hardware.graphics.extraPackages = lib.mkForce [
    pkgs.intel-media-driver # VAAPI for video decode/encode
    pkgs.intel-vaapi-driver # Older VAAPI driver (backup)
    pkgs.vpl-gpu-rt # Intel Quick Sync Video
  ];

  # ==========================================================================
  # Host Identity
  # ==========================================================================
  networking.hostName = "sleeper-service";

  # ==========================================================================
  # Locale & Time
  # ==========================================================================
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  # Note: console keymap derived from XKB config (see modules/nixos/system.nix)

  # ==========================================================================
  # Users
  # ==========================================================================
  users.users.john = {
    isNormalUser = true;
    description = "John";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
    ];
    shell = pkgs.zsh;
  };

  # Enable zsh system-wide (required for user shell)
  programs.zsh.enable = true;

  # ==========================================================================
  # Desktop Environment
  # ==========================================================================
  desktop.enable = true;

  # ==========================================================================
  # Browser: Helium via AppImage
  # ==========================================================================
  programs.appimage = {
    enable = true;
    binfmt = true; # Allow running AppImages directly
  };

  # Flatpak as fallback for other apps
  services.flatpak.enable = true;

  # ==========================================================================
  # Theme
  # ==========================================================================
  themes.scheme = "nord";
  themes.mode = "dark";

  # ==========================================================================
  # System Packages
  # ==========================================================================
  environment.systemPackages = with pkgs; [
    # Core utilities
    vim
    wget
    curl
    git

    # AppImage support
    appimage-run
  ];

  # ==========================================================================
  # NixOS Release
  # ==========================================================================
  system.stateVersion = "25.05";
}
