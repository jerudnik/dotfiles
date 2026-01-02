# Shared NixOS configuration for all NixOS hosts
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    # Cross-platform theming
    ../../../modules/base/stylix.nix
  ];

  # ==========================================================================
  # Nix Settings
  # ==========================================================================
  nix = {
    settings = {
      # Enable flakes and new nix command
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Trusted users for remote builds and caching
      trusted-users = [
        "root"
        "@wheel"
      ];

      # Harmonia cache (mac-studio)
      extra-substituters = [
        "http://serious-callers-only:5000"
      ];
      extra-trusted-public-keys = [
        "serious-callers-only-1:J/+Orh0qfTKuVEm//2bA0bXKnTmXGjT02FHu9AK9IxU="
      ];

      # Optimize storage
      auto-optimise-store = true;
    };

    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # ==========================================================================
  # Boot
  # ==========================================================================
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # ==========================================================================
  # Networking
  # ==========================================================================
  networking.networkmanager.enable = true;

  # ==========================================================================
  # Hardware
  # ==========================================================================
  hardware.enableRedistributableFirmware = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # ==========================================================================
  # Audio (PipeWire)
  # ==========================================================================
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Disable PulseAudio (using PipeWire instead)
  services.pulseaudio.enable = false;

  # RealtimeKit for audio priority
  security.rtkit.enable = true;

  # ==========================================================================
  # Security Defaults
  # ==========================================================================
  security.polkit.enable = true;

  # ==========================================================================
  # XDG Portal (required for Wayland screen sharing, file dialogs, etc.)
  # ==========================================================================
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

}
