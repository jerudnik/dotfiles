# NixOS system configuration
# Core system settings that apply to all NixOS hosts
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # ==========================================================================
  # Console
  # ==========================================================================
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # Use xkb options in console
  };

  # ==========================================================================
  # Fonts
  # ==========================================================================
  fonts = {
    packages = with pkgs; [
      # Serif
      ibm-plex

      # Sans-serif and Monospace (Nerd Font patched)
      nerd-fonts.im-writing

      # Emoji
      noto-fonts-color-emoji
      noto-fonts

      # Fallback fonts
      liberation_ttf
      dejavu_fonts
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "IBM Plex Serif" ];
        sansSerif = [ "iMWritingQuatSS Nerd Font" ];
        monospace = [ "iMWritingMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # ==========================================================================
  # Environment
  # ==========================================================================
  environment = {
    # System-wide environment variables
    sessionVariables = {
      # Wayland
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";

      # XDG
      XDG_SESSION_TYPE = "wayland";
    };

    # Essential system packages
    systemPackages = with pkgs; [
      # File systems
      ntfs3g
      exfat

      # Archives
      unzip
      zip
      p7zip

      # System utilities
      pciutils
      usbutils
      lsof
      htop
      btop

      # Networking
      iw
      wirelesstools
    ];
  };

  # ==========================================================================
  # Programs
  # ==========================================================================
  programs = {
    # Enable dconf (required for GTK settings)
    dconf.enable = true;

    # GPG agent
    gnupg.agent = {
      enable = true;
      enableSSHSupport = false; # Using FIDO2 keys instead
    };
  };

  # ==========================================================================
  # Services
  # ==========================================================================
  services = {
    # D-Bus
    dbus.enable = true;

    # GVFS for trash, network mounts, etc.
    gvfs.enable = true;

    # Thumbnail service
    tumbler.enable = true;

    # Printing (disabled by default, enable per-host if needed)
    printing.enable = lib.mkDefault false;

    # Firmware updates
    fwupd.enable = true;
  };
}
