# Home Manager configuration for john on Linux/NixOS
{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../../modules/home/shell
    ../../modules/home/git.nix
    ../../modules/home/ssh.nix
    ../../modules/home/editors
    ../../modules/home/packages.nix
    ../../modules/home/development.nix
    ../../modules/home/python-tools.nix
    ../../modules/home/ai
    ../../modules/home/apps/linux
    # Terminal - using wezterm, ghostty commented for now
    ../../modules/home/terminal/wezterm.nix
    # ../../modules/home/terminal/ghostty.nix
  ];

  home = {
    username = "john";
    homeDirectory = "/home/john";
    stateVersion = "24.11";
  };

  # Hyprland configuration via home-manager
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Monitor configuration - HiDPI scaling for Pixelbook
      monitor = [ ",preferred,auto,2" ];

      # Input configuration
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
          drag_lock = true;
          disable_while_typing = true;
        };
        sensitivity = 0;
      };

      # General settings
      general = {
        gaps_in = 6;
        gaps_out = 12;
        border_size = 2;
        "col.active_border" = lib.mkForce "rgba(88c0d0ff) rgba(81a1c1ff) 45deg";
        "col.inactive_border" = lib.mkForce "rgba(4c566aaa)";
        layout = "dwindle";
        allow_tearing = false;
      };

      # Decoration - ChromeOS-inspired rounded corners, minimal blur for performance
      decoration = {
        rounding = 12;
        blur = {
          enabled = false; # Disabled for better performance on older GPU
        };
        shadow = {
          enabled = true;
          range = 8;
          render_power = 2;
          color = lib.mkForce "rgba(1a1a1aee)";
        };
      };

      # Animations - subtle for older hardware
      animations = {
        enabled = true;
        bezier = "ease, 0.25, 0.1, 0.25, 1.0";
        animation = [
          "windows, 1, 4, ease, slide"
          "windowsOut, 1, 4, ease, slide"
          "fade, 1, 4, ease"
          "workspaces, 1, 3, ease, slide"
        ];
      };

      # Layout
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Misc - performance optimizations
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        vfr = true; # Variable frame rate for power saving
      };

      # Gestures for touchpad
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
      };

      # Keybindings
      "$mod" = "SUPER";
      "$terminal" = "wezterm";
      "$menu" = "rofi -show drun";

      bind = [
        # Core bindings
        "$mod, SPACE, exec, $menu"
        "$mod, RETURN, exec, $terminal"
        "$mod, Q, killactive,"
        "$mod, L, exec, hyprlock"
        "$mod, M, exit,"
        "$mod, E, exec, thunar"
        "$mod, V, togglefloating,"
        "$mod, P, pseudo,"
        "$mod, J, togglesplit,"

        # Screenshot
        "$mod SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy"
        ", Print, exec, grim - | wl-copy"

        # Move focus
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move windows to workspaces
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Scroll through workspaces
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # Media keys
        ", XF86AudioRaiseVolume, exec, pamixer -i 5"
        ", XF86AudioLowerVolume, exec, pamixer -d 5"
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86MonBrightnessUp, exec, brightnessctl set +10%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Startup applications
      exec-once = [
        "waybar"
        "mako"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      # Window rules
      windowrulev2 = [
        "float, class:^(pavucontrol)$"
        "float, class:^(blueman-manager)$"
        "float, class:^(nm-connection-editor)$"
        "float, title:^(Picture-in-Picture)$"
        "float, class:^(imv)$"
      ];
    };
  };

  # Waybar configuration - ChromeOS-inspired
  programs.waybar = {
    enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        margin = "8 8 0 8";
        spacing = 8;
        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "network"
          "pulseaudio"
          "battery"
          "tray"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
          all-outputs = true;
        };

        "hyprland/window" = {
          max-length = 40;
          icon = true;
        };

        clock = {
          format = "{:%a %b %d  %H:%M}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            weeks-pos = "right";
            format = {
              months = "<span color='#88c0d0'><b>{}</b></span>";
              days = "<span color='#e5e9f0'>{}</span>";
              weeks = "<span color='#81a1c1'>W{}</span>";
              weekdays = "<span color='#88c0d0'>{}</span>";
              today = "<span color='#bf616a'><b><u>{}</u></b></span>";
            };
          };
        };

        network = {
          format-wifi = "  {essid}";
          format-ethernet = "  {ipaddr}";
          format-disconnected = "󰖪  Disconnected";
          tooltip-format = "{ifname}: {ipaddr}";
          on-click = "nm-connection-editor";
        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "  Muted";
          format-icons = {
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "pavucontrol";
        };

        battery = {
          format = "{icon}  {capacity}%";
          format-charging = "  {capacity}%";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
          states = {
            warning = 30;
            critical = 15;
          };
        };

        tray = {
          spacing = 8;
        };
      }
    ];

    style = ''
      * {
        font-family: "iMWritingMono Nerd Font", "Noto Color Emoji";
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(46, 52, 64, 0.85);
        border-radius: 16px;
        border: 1px solid rgba(76, 86, 106, 0.6);
        color: #e5e9f0;
      }

      #workspaces button {
        padding: 4px 10px;
        margin: 4px 2px;
        border-radius: 12px;
        background: transparent;
        color: #e5e9f0;
        border: none;
      }

      #workspaces button.active {
        background: #88c0d0;
        color: #2e3440;
      }

      #workspaces button:hover {
        background: rgba(136, 192, 208, 0.3);
      }

      #window,
      #clock,
      #network,
      #pulseaudio,
      #battery,
      #tray {
        padding: 4px 12px;
        margin: 4px 2px;
        border-radius: 12px;
        background: rgba(76, 86, 106, 0.4);
      }

      #clock {
        font-weight: bold;
      }

      #battery.warning {
        background: #ebcb8b;
        color: #2e3440;
      }

      #battery.critical {
        background: #bf616a;
        color: #eceff4;
      }

      tooltip {
        background: #3b4252;
        border: 1px solid #4c566a;
        border-radius: 12px;
      }
    '';
  };

  # Rofi configuration - let Stylix handle theming
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    terminal = "wezterm";
    extraConfig = {
      modi = "drun,run";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      display-drun = "Apps";
      drun-display-format = "{name}";
    };
  };

  # Mako notifications - Nord themed
  services.mako = {
    enable = true;
    settings = {
      anchor = "top-right";
      background-color = lib.mkForce "#2e3440ee";
      border-color = lib.mkForce "#4c566a";
      border-radius = 12;
      border-size = 2;
      text-color = lib.mkForce "#e5e9f0";
      padding = "12";
      margin = "12";
      width = 360;
      font = lib.mkForce "iMWritingMono Nerd Font 12";
      default-timeout = 5000;
    };
  };

  # Hypridle configuration
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "brightnessctl -s set 10%";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  # Hyprlock configuration
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        grace = 5;
      };
      background = lib.mkForce [
        {
          monitor = "";
          color = "rgba(46, 52, 64, 1.0)";
          blur_passes = 0;
        }
      ];
      label = [
        {
          monitor = "";
          text = "$TIME";
          color = "rgba(229, 233, 240, 1.0)";
          font_size = 72;
          font_family = "IBM Plex Serif";
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "Type password to unlock";
          color = "rgba(136, 192, 208, 1.0)";
          font_size = 14;
          font_family = "iMWritingMono Nerd Font";
          position = "0, -100";
          halign = "center";
          valign = "center";
        }
      ];
      input-field = lib.mkForce [
        {
          monitor = "";
          size = "300, 50";
          position = "0, -30";
          outline_thickness = 2;
          dots_size = 0.25;
          dots_spacing = 0.3;
          outer_color = "rgba(136, 192, 208, 1.0)";
          inner_color = "rgba(76, 86, 106, 0.5)";
          font_color = "rgba(229, 233, 240, 1.0)";
          fade_on_empty = false;
          placeholder_text = "";
          hide_input = false;
          rounding = 12;
        }
      ];
    };
  };

  # Enable XDG user directories
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
