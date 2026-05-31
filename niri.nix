{
  config,
  rustScripts,
  ...
}:

{
  programs.niri = {
    settings = {
      input = {
        keyboard = {
          xkb.layout = "es";
          numlock = true;
        };
        touchpad = {
          tap = true;
          natural-scroll = true;
        };
        mouse = {
          accel-speed = 0.0;
          accel-profile = "flat";
        };
      };

      outputs."DP-1" = {
        mode = {
          width = 2560;
          height = 1440;
          refresh = 143.972;
        };
        scale = 1;
        position = {
          x = 0;
          y = 0;
        };
        variable-refresh-rate = "on-demand";
      };

      layout = {
        gaps = 8;
        center-focused-column = "never";
        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];
        default-column-width = {
          proportion = 0.5;
        };
        focus-ring = {
          width = 1;
          active.color = "#${config.colors.primary}";
          inactive.color = "#${config.colors.outline}";
        };
        border = {
          enable = false;
          active.color = "#${config.colors.primary}";
          inactive.color = "#${config.colors.outline}";
          urgent.color = "#${config.colors.error}";
        };
        shadow = {
          softness = 30;
          spread = 5;
          offset = {
            x = 0;
            y = 5;
          };
          color = "#${config.colors.shadow}70";
        };
        tab-indicator = {
          active.color = "#${config.colors.primary}";
          inactive.color = "#${config.colors.outline}";
          urgent.color = "#${config.colors.error}";
        };
        insert-hint = {
          display.color = "#${config.colors.primary}80";
        };
      };

      overview = {
        backdrop-color = "#${config.colors.surface}";
      };

      spawn-at-startup = [
        { command = [ "/usr/lib/soteria-polkit/soteria" ]; }
        {
          command = [
            "fcitx5"
            "-d"
          ];
        }
        {
          command = [
            "wl-clip-persist"
            "--clipboard"
            "regular"
          ];
        }
        { command = [ "ironbar" ]; }
        { command = [ "quickshell" ]; }
        { sh = "swaybg -i ${config.xdg.dataHome}/wallpaper.jpg"; }
      ];

      hotkey-overlay.skip-at-startup = true;

      environment = {
        QT_QPA_PLATFORM = "wayland";
        QT_QPA_PLATFORMTHEME = "qt6ct";
        XMODIFIERS = "@im=fcitx";
      };

      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      window-rules = [
        {
          matches = [
            {
              app-id = "^steam_app_.*$";

            }
            {
              app-id = "cs2";
            }
          ];
          variable-refresh-rate = true;
        }
        {
          geometry-corner-radius = {
            bottom-left = 12.;
            bottom-right = 12.;
            top-left = 12.;
            top-right = 12.;
          };
          clip-to-geometry = true;
        }
      ];

      binds = {
        "Mod+Shift+7".action.show-hotkey-overlay = [ ];
        "Mod+T" = {
          action.spawn = [
            "ghostty"
            "+new-window"
          ];
          hotkey-overlay.title = "Open a Terminal: ghostty";
        };
        "Mod+D" = {
          action.spawn = [ "fuzzel" ];
          hotkey-overlay.title = "Run an Application: fuzzel";
        };
        "Super+Alt+L" = {
          action.spawn = [ "swaylock" ];
          hotkey-overlay.title = "Lock the Screen: swaylock";
        };

        "XF86AudioRaiseVolume" = {
          action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
          allow-when-locked = true;
        };
        "XF86AudioLowerVolume" = {
          action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
          allow-when-locked = true;
        };
        "XF86AudioMute" = {
          action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          allow-when-locked = true;
        };
        "XF86AudioMicMute" = {
          action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          allow-when-locked = true;
        };

        "Mod+O" = {
          action.toggle-overview = [ ];
          repeat = false;
        };
        "Mod+Q" = {
          action.close-window = [ ];
          repeat = false;
        };

        "Mod+Left".action.focus-column-left = [ ];
        "Mod+Down".action.focus-window-down = [ ];
        "Mod+Up".action.focus-window-up = [ ];
        "Mod+Right".action.focus-column-right = [ ];
        "Mod+H".action.focus-column-left = [ ];
        "Mod+J".action.focus-window-down = [ ];
        "Mod+K".action.focus-window-up = [ ];
        "Mod+L".action.focus-column-right = [ ];

        "Mod+Ctrl+Left".action.move-column-left = [ ];
        "Mod+Ctrl+Down".action.move-window-down = [ ];
        "Mod+Ctrl+Up".action.move-window-up = [ ];
        "Mod+Ctrl+Right".action.move-column-right = [ ];
        "Mod+Ctrl+H".action.move-column-left = [ ];
        "Mod+Ctrl+J".action.move-window-down = [ ];
        "Mod+Ctrl+K".action.move-window-up = [ ];
        "Mod+Ctrl+L".action.move-column-right = [ ];

        "Mod+Home".action.focus-column-first = [ ];
        "Mod+End".action.focus-column-last = [ ];
        "Mod+Ctrl+Home".action.move-column-to-first = [ ];
        "Mod+Ctrl+End".action.move-column-to-last = [ ];

        "Mod+Shift+Left".action.focus-monitor-left = [ ];
        "Mod+Shift+Down".action.focus-monitor-down = [ ];
        "Mod+Shift+Up".action.focus-monitor-up = [ ];
        "Mod+Shift+Right".action.focus-monitor-right = [ ];

        "Mod+Page_Down".action.focus-workspace-down = [ ];
        "Mod+Page_Up".action.focus-workspace-up = [ ];
        "Mod+U".action.focus-workspace-down = [ ];
        "Mod+I".action.focus-workspace-up = [ ];

        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;

        "Mod+Ctrl+1".action.move-column-to-workspace = 1;
        "Mod+Ctrl+2".action.move-column-to-workspace = 2;
        "Mod+Ctrl+3".action.move-column-to-workspace = 3;
        "Mod+Ctrl+4".action.move-column-to-workspace = 4;
        "Mod+Ctrl+5".action.move-column-to-workspace = 5;
        "Mod+Ctrl+6".action.move-column-to-workspace = 6;
        "Mod+Ctrl+7".action.move-column-to-workspace = 7;
        "Mod+Ctrl+8".action.move-column-to-workspace = 8;
        "Mod+Ctrl+9".action.move-column-to-workspace = 9;

        "Mod+dead_grave".action.consume-or-expel-window-left = [ ];
        "Mod+Plus".action.consume-or-expel-window-right = [ ];
        "Mod+Comma".action.consume-window-into-column = [ ];
        "Mod+Period".action.expel-window-from-column = [ ];

        "Mod+R".action.switch-preset-column-width = [ ];
        "Mod+Shift+R".action.switch-preset-window-height = [ ];
        "Mod+Ctrl+R".action.reset-window-height = [ ];
        "Mod+F".action.maximize-column = [ ];
        "Mod+Shift+F".action.fullscreen-window = [ ];
        "Mod+C".action.center-column = [ ];

        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";
        "Mod+Shift+Minus".action.set-window-height = "-10%";
        "Mod+Shift+Equal".action.set-window-height = "+10%";

        "Mod+V".action.toggle-window-floating = [ ];
        "Mod+W".action.toggle-column-tabbed-display = [ ];

        "Print".action.screenshot = [ ];
        "Ctrl+Print".action.screenshot-screen = [ ];
        "Alt+Print".action.screenshot-window = [ ];

        "Mod+Escape" = {
          action.toggle-keyboard-shortcuts-inhibit = [ ];
          allow-inhibiting = false;
        };

        "Mod+Shift+N" = {
          action.spawn = [
            "sh"
            "-c"
            "${rustScripts}/bin/networkmenu"
          ];
          hotkey-overlay.title = "Network Menu";
        };
        "Mod+Shift+E" = {
          action.spawn = [
            "sh"
            "-c"
            "${rustScripts}/bin/powermenu"
          ];
          hotkey-overlay.title = "Power Menu";
        };
        "Ctrl+Alt+Delete".action.quit = [ ];
      };
    };
  };
}
