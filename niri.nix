{
  config,
  rustScripts,
  ...
}:

{
  wayland.windowManager.niri = {
    enable = true;
    package = null;
    portalPackage = null;
    xwaylandSatellitePackage = null;
    systemd.enable = false;
    settings = {
      input = {
        keyboard = {
          xkb.layout = "es";
          numlock = true;
        };
        touchpad = {
          tap = [ ];
          natural-scroll = [ ];
        };
        mouse = {
          accel-speed = 0.0;
          accel-profile = "flat";
        };
      };

      output = {
        _args = [ "DP-1" ];
        mode = "2560x1440@143.972";
        scale = 1;
        position = {
          _props.x = 0;
          _props.y = 0;
        };
        variable-refresh-rate = {
          _props.on-demand = true;
        };
      };

      layout = {
        gaps = 8;
        center-focused-column = "never";
        preset-column-widths._children = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];
        default-column-width = {
          proportion = 0.5;
        };
        focus-ring = {
          off = [ ];
          width = 1;
          active-color = "#${config.colors.primary}";
          inactive-color = "#${config.colors.outline}";
        };
        border = {
          off = [ ];
          active-color = "#${config.colors.primary}";
          inactive-color = "#${config.colors.outline}";
          urgent-color = "#${config.colors.error}";
        };
        shadow = {
          softness = 30;
          spread = 5;
          offset = {
            _props.x = 0;
            _props.y = 5;
          };
          color = "#${config.colors.shadow}70";
        };
        tab-indicator = {
          active-color = "#${config.colors.primary}";
          inactive-color = "#${config.colors.outline}";
          urgent-color = "#${config.colors.error}";
        };
        insert-hint = {
          color = "#${config.colors.primary}80";
        };
      };

      overview = {
        backdrop-color = "#${config.colors.surface}";
      };

      hotkey-overlay.skip-at-startup = true;

      environment = {
        QT_QPA_PLATFORM = "wayland";
        QT_QPA_PLATFORMTHEME = "qt6ct";
        XMODIFIERS = "@im=fcitx";
      };

      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      _children = [
        {
          window-rule = {
            _children = [
              {
                match._props.app-id = "^steam_app_.*$";
              }
              { match._props.app-id = "cs2"; }
            ];
            variable-refresh-rate = true;
          };
        }
        {
          window-rule = {
            geometry-corner-radius = 12;
            clip-to-geometry = true;
          };
        }
        { spawn-at-startup = [ "/usr/lib/soteria-polkit/soteria" ]; }
        {
          spawn-at-startup = [
            "fcitx5"
            "-d"
          ];
        }
        {
          spawn-at-startup = [
            "wl-clip-persist"
            "--clipboard"
            "regular"
          ];
        }
        { spawn-at-startup = [ "ironbar" ]; }
        { spawn-at-startup = [ "quickshell" ]; }
        { spawn-sh-at-startup = "swaybg -i ${config.xdg.dataHome}/wallpaper.jpg"; }
      ];

      binds = {
        "Mod+Shift+7".show-hotkey-overlay = [ ];
        "Mod+T" = {
          spawn = [
            "ghostty"
            "+new-window"
          ];
          _props.hotkey-overlay-title = "Open a Terminal: ghostty";
        };
        "Mod+D" = {
          spawn = [ "fuzzel" ];
          _props.hotkey-overlay-title = "Run an Application: fuzzel";
        };
        "Super+Alt+L" = {
          spawn = [ "swaylock" ];
          _props.hotkey-overlay-title = "Lock the Screen: swaylock";
        };

        "XF86AudioRaiseVolume" = {
          spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
          _props.allow-when-locked = true;
        };
        "XF86AudioLowerVolume" = {
          spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
          _props.allow-when-locked = true;
        };
        "XF86AudioMute" = {
          spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          _props.allow-when-locked = true;
        };
        "XF86AudioMicMute" = {
          spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          _props.allow-when-locked = true;
        };

        "Mod+O" = {
          toggle-overview = [ ];
          _props.repeat = false;
        };
        "Mod+Q" = {
          close-window = [ ];
          _props.repeat = false;
        };

        "Mod+Left".focus-column-left = [ ];
        "Mod+Down".focus-window-down = [ ];
        "Mod+Up".focus-window-up = [ ];
        "Mod+Right".focus-column-right = [ ];
        "Mod+H".focus-column-left = [ ];
        "Mod+J".focus-window-down = [ ];
        "Mod+K".focus-window-up = [ ];
        "Mod+L".focus-column-right = [ ];

        "Mod+Ctrl+Left".move-column-left = [ ];
        "Mod+Ctrl+Down".move-window-down = [ ];
        "Mod+Ctrl+Up".move-window-up = [ ];
        "Mod+Ctrl+Right".move-column-right = [ ];
        "Mod+Ctrl+H".move-column-left = [ ];
        "Mod+Ctrl+J".move-window-down = [ ];
        "Mod+Ctrl+K".move-window-up = [ ];
        "Mod+Ctrl+L".move-column-right = [ ];

        "Mod+Home".focus-column-first = [ ];
        "Mod+End".focus-column-last = [ ];
        "Mod+Ctrl+Home".move-column-to-first = [ ];
        "Mod+Ctrl+End".move-column-to-last = [ ];

        "Mod+Shift+Left".focus-monitor-left = [ ];
        "Mod+Shift+Down".focus-monitor-down = [ ];
        "Mod+Shift+Up".focus-monitor-up = [ ];
        "Mod+Shift+Right".focus-monitor-right = [ ];

        "Mod+Page_Down".focus-workspace-down = [ ];
        "Mod+Page_Up".focus-workspace-up = [ ];
        "Mod+U".focus-workspace-down = [ ];
        "Mod+I".focus-workspace-up = [ ];

        "Mod+1".focus-workspace = 1;
        "Mod+2".focus-workspace = 2;
        "Mod+3".focus-workspace = 3;
        "Mod+4".focus-workspace = 4;
        "Mod+5".focus-workspace = 5;
        "Mod+6".focus-workspace = 6;
        "Mod+7".focus-workspace = 7;
        "Mod+8".focus-workspace = 8;
        "Mod+9".focus-workspace = 9;

        "Mod+Ctrl+1".move-column-to-workspace = 1;
        "Mod+Ctrl+2".move-column-to-workspace = 2;
        "Mod+Ctrl+3".move-column-to-workspace = 3;
        "Mod+Ctrl+4".move-column-to-workspace = 4;
        "Mod+Ctrl+5".move-column-to-workspace = 5;
        "Mod+Ctrl+6".move-column-to-workspace = 6;
        "Mod+Ctrl+7".move-column-to-workspace = 7;
        "Mod+Ctrl+8".move-column-to-workspace = 8;
        "Mod+Ctrl+9".move-column-to-workspace = 9;

        "Mod+dead_grave".consume-or-expel-window-left = [ ];
        "Mod+Plus".consume-or-expel-window-right = [ ];
        "Mod+Comma".consume-window-into-column = [ ];
        "Mod+Period".expel-window-from-column = [ ];

        "Mod+R".switch-preset-column-width = [ ];
        "Mod+Shift+R".switch-preset-window-height = [ ];
        "Mod+Ctrl+R".reset-window-height = [ ];
        "Mod+F".maximize-column = [ ];
        "Mod+Shift+F".fullscreen-window = [ ];
        "Mod+C".center-column = [ ];

        "Mod+Minus".set-column-width = "-10%";
        "Mod+Equal".set-column-width = "+10%";
        "Mod+Shift+Minus".set-window-height = "-10%";
        "Mod+Shift+Equal".set-window-height = "+10%";

        "Mod+V".toggle-window-floating = [ ];
        "Mod+W".toggle-column-tabbed-display = [ ];

        "Print".screenshot = [ ];
        "Ctrl+Print".screenshot-screen = [ ];
        "Alt+Print".screenshot-window = [ ];

        "Mod+Escape" = {
          toggle-keyboard-shortcuts-inhibit = [ ];
          _props.allow-inhibiting = false;
        };

        "Mod+Shift+N" = {
          spawn = [
            "sh"
            "-c"
            "${rustScripts}/bin/networkmenu"
          ];
          _props.hotkey-overlay-title = "Network Menu";
        };
        "Mod+Shift+E" = {
          spawn = [
            "sh"
            "-c"
            "${rustScripts}/bin/powermenu"
          ];
          _props.hotkey-overlay-title = "Power Menu";
        };
        "Ctrl+Alt+Delete".quit = [ ];
      };
    };
  };
}
