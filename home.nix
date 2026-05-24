{
  config,
  pkgs,
  lib,
  ...
}:

let
  rustScripts = pkgs.callPackage ./rust-scripts { };
in
{
  _module.args = {
    rustScripts = rustScripts;
  };

  imports = [
    ./options.nix
    ./niri.nix
    ./ironbar.nix
    ./matugen.nix
  ];

  home.username = "david";
  home.homeDirectory = "/home/david";
  home.stateVersion = "25.11";

  home.packages = [
    pkgs.pywalfox-native
    rustScripts
  ];

  xdg.dataFile."wallpaper.jpg".source = ./wallpaper.jpg;

  home.sessionVariables = {

  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.ghcup/bin"
  ];

  home.activation = {
    reloadApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ironbar reload || true
      $DRY_RUN_CMD systemctl reload --user app-com.mitchellh.ghostty.service || true
    '';
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = "set -g fish_greeting";
  };

  programs.ghostty = {
    enable = true;
    package = null;
    systemd.enable = false;
    settings = {
      command = "fish";
      keybind = [
        "performable:ctrl+c=copy_to_clipboard"
      ];
      right-click-action = "paste";
      quit-after-last-window-closed = false;
      gtk-titlebar-style = "tabs";
      gtk-wide-tabs = false;
      font-family = "'Inconsolata'";
      term = "ghostty";
      shell-integration-features = "ssh-env";
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings =
      let
        programmingLangIcons = {
          nodejs = "";
          rust = "";
          golang = "";
          php = "";
          python = "";
          haskell = "";
        };
        programmingLangCommon = {
          style = "bg:#${config.colors.on_primary}";
          format = "[[ $symbol ($version) ](fg:#${config.colors.primary} bg:#${config.colors.on_primary})]($style)";
        };
      in
      {
        format = lib.concatStrings [
          "[](#${config.colors.surface_variant})"
          "[󰣇 ](bg:#${config.colors.surface_variant} fg:#${config.colors.on_surface_variant})"
          "[](bg:#${config.colors.primary} fg:#${config.colors.surface_variant})"
          "$directory"
          "[](bg:#${config.colors.primary_container} fg:#${config.colors.primary})"
          "$git_branch"
          "$git_status"
          "[](bg:#${config.colors.on_primary} fg:#${config.colors.primary_container})"
          "$nodejs"
          "$rust"
          "$golang"
          "$php"
          "$python"
          "$haskell"
          "[](#${config.colors.on_primary})"
          "$line_break"
          "$character"
        ];
        directory = {
          style = "fg:#${config.colors.on_primary} bg:#${config.colors.primary}";
          format = "[ $path ]($style)";
          truncation_length = 3;
          truncation_symbol = "…/";
        };
        character = {
          success_symbol = "[❯](#${config.colors.primary})";
          error_symbol = "[❯](#${config.colors.error})";
        };
        git_branch = {
          symbol = "";
          style = "bg:#${config.colors.primary_container}";
          format = "[[ $symbol $branch ](fg:#${config.colors.on_primary_container} bg:#${config.colors.primary_container})]($style)";
        };
        git_status = {
          style = "bg:#${config.colors.primary_container}";
          format = "[[($all_status$ahead_behind )](fg:#${config.colors.on_primary_container} bg:#${config.colors.primary_container})]($style)";
        };
        time.disabled = true;
      }
      // (lib.mapAttrs (_: icon: programmingLangCommon // { symbol = icon; }) programmingLangIcons);
  };

  programs.quickshell = {
    enable = true;
    package = null;
    configs."." = pkgs.runCommand "quickshell" { } ''
      mkdir -p $out
      cp -rH ${./quickshell}/. $out/
      ln -s ${pkgs.writeText "Colors.qml" ''
        import QtQuick
        QtObject {
          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList (k: v: "    readonly property color ${k}: \"#${v}\"") config.colors
          )}
        }
      ''} $out/Colors.qml
    '';
  };

  programs.fuzzel = {
    enable = true;
    package = null;
    settings = {
      main = {
        font = "sans-serif";
        inner-pad = 4;
        show-actions = true;
        icon-theme = "WhiteSur-dark";
      };
      border = {
        width = 0;
        radius = 12;
        selection-radius = 4;
      };
    };
  };

  programs.bat.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  services.mako = {
    enable = true;
    package = null;
    settings = {
      default-timeout = 5000;
      font = "sans-serif 10";
      padding = 10;
      outer-margin = 5;
      margin = 5;
      border-size = 0;
      border-radius = 8;
      height = 1440;
      background-color = "#${config.colors.surface_container_high}";
      text-color = "#${config.colors.on_surface}";
      "mode=do-not-disturb" = {
        invisible = 1;
        on-notify = "none";
      };
      "mode=silent" = {
        on-notify = "none";
      };
      "urgency=high" = {
        border-size = 1;
        border-color = "#${config.colors.error_container}";
      };
    };
  };

  gtk = {
    enable = true;
    colorScheme = "dark";
    gtk3.theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };
  };

  qt = {
    enable = true;
  };

  programs.home-manager.enable = true;
}
