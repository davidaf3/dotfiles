{
  config,
  pkgs,
  lib,
  ...
}:

let
  qtctColorScheme = lib.concatStringsSep ", " [
    "#${config.colors.on_background}"
    "#${config.colors.surface}"
    "#ffffff"
    "#cacaca"
    "#9f9f9f"
    "#b8b8b8"
    "#${config.colors.on_background}"
    "#ffffff"
    "#${config.colors.on_surface}"
    "#${config.colors.background}"
    "#${config.colors.background}"
    "#${config.colors.shadow}"
    "#${config.colors.primary_container}"
    "#${config.colors.on_primary_container}"
    "#${config.colors.secondary}"
    "#${config.colors.primary}"
    "#${config.colors.surface}"
    "#${config.colors.scrim}"
    "#${config.colors.surface}"
    "#${config.colors.on_surface}"
    "#${config.colors.secondary}"
  ];
  qtctColorSchemeINI = lib.generators.toINI { } {
    ColorScheme = {
      active_colors = qtctColorScheme;
      disabled_colors = qtctColorScheme;
      inactive_colors = qtctColorScheme;
    };
  };
in
{
  programs.matugen = {
    enable = true;
    variant = "dark";
    type = "scheme-vibrant";
    wallpaper = ./wallpaper.jpg;
  };

  colors = builtins.mapAttrs (name: value: value.default.color) config.programs.matugen.theme.colors;

  home.file.".cache/wal/colors.json" = {
    onChange = "${lib.getExe pkgs.pywalfox-native} update";
    text = ''
      {
        "wallpaper": "${./wallpaper.jpg}",
        "alpha": "100",
        "colors": {
          "color0": "#${config.colors.surface}",
          "color1": "#${config.colors.surface_container}",
          "color2": "#${config.colors.surface_container_high}",
          "color3": "",
          "color4": "",
          "color5": "",
          "color6": "",
          "color7": "",
          "color8": "",
          "color9": "",
          "color10": "#${config.colors.primary}",
          "color11": "",
          "color12": "",
          "color13": "#${config.colors.secondary}",
          "color14": "",
          "color15": "#${config.colors.on_surface}"
        }
      }
    '';
  };

  home.activation.installPywalfox =
    lib.hm.dag.entryBetween [ "installPackages" ] [ "onFilesChange" ]
      ''
        $DRY_RUN_CMD ${pkgs.pywalfox-native}/bin/pywalfox install
      '';

  home.file.".vscode-oss/extensions/matugen-theme/package.json".text = builtins.toJSON {
    name = "matugen-theme";
    displayName = "Matugen Theme";
    description = "Matugen theme";
    version = "1.0.0";
    publisher = "me";
    engines.vscode = "^1.70.0";
    categories = [ "Themes" ];
    contributes.configurationDefaults."workbench.colorCustomizations"."[Dark+]" = {
      "activityBar.background" = "#${config.colors.surface_container}";
      "sideBar.background" = "#${config.colors.surface_container}";
      "sideBarSectionHeader.background" = "#${config.colors.surface_container}";
      "titleBar.activeBackground" = "#${config.colors.surface_container}";
      "titleBar.inactiveBackground" = "#${config.colors.surface_container}";
      "editorGroupHeader.tabsBackground" = "#${config.colors.surface_container}";
      "panel.background" = "#${config.colors.surface_container}";
      "statusBar.background" = "#${config.colors.surface_container}";
      "editor.background" = "#${config.colors.surface}";
      "editor.foreground" = "#${config.colors.on_surface}";
      "tab.activeBackground" = "#${config.colors.surface}";
      "tab.activeForeground" = "#${config.colors.primary}";
      "tab.activeBorderTop" = "#${config.colors.primary}";
      "tab.inactiveBackground" = "#${config.colors.surface_container}";
      "tab.inactiveForeground" = "#${config.colors.on_surface_variant}";
      "sideBar.border" = "#${config.colors.outline_variant}";
      "activityBar.border" = "#${config.colors.outline_variant}";
      "editorGroup.border" = "#${config.colors.outline_variant}";
      "panel.border" = "#${config.colors.outline_variant}";
      "statusBar.border" = "#${config.colors.outline_variant}";
      "titleBar.border" = "#${config.colors.outline_variant}";
      "tab.border" = "#${config.colors.outline_variant}";
      "list.activeSelectionBackground" = "#${config.colors.primary_container}";
      "list.activeSelectionForeground" = "#${config.colors.on_primary_container}";
      "list.hoverBackground" = "#${config.colors.surface_container_highest}";
      "activityBar.foreground" = "#${config.colors.primary}";
      "focusBorder" = "#${config.colors.primary}";
      "statusBar.foreground" = "#${config.colors.on_surface}";
      "menu.background" = "#${config.colors.surface_container_high}";
      "editorHoverWidget.background" = "#${config.colors.surface_container_high}";
      "editorWidget.background" = "#${config.colors.surface_container_high}";
    };
  };

  xdg.dataFile."color-schemes/Matugen.colors".text = ''
    [ColorEffects:Disabled]
    Color=#${config.colors.on_surface}
    ColorAmount=0
    ColorEffect=0
    ContrastAmount=0.65
    ContrastEffect=1
    IntensityAmount=0.1
    IntensityEffect=2

    [ColorEffects:Inactive]
    ChangeSelectionColor=true
    Color=#${config.colors.on_surface_variant}
    ColorAmount=0.025
    ColorEffect=2
    ContrastAmount=0.1
    ContrastEffect=2
    Enable=false
    IntensityAmount=0
    IntensityEffect=0

    [Colors:Button]
    BackgroundAlternate=#${config.colors.secondary_container}
    BackgroundNormal=#${config.colors.surface}
    DecorationFocus=#${config.colors.primary}
    DecorationHover=#${config.colors.primary}
    ForegroundActive=#${config.colors.primary}
    ForegroundInactive=#${config.colors.on_surface_variant}
    ForegroundLink=#${config.colors.primary}
    ForegroundNegative=#${config.colors.error}
    ForegroundNeutral=#${config.colors.secondary}
    ForegroundNormal=#${config.colors.on_surface}
    ForegroundPositive=#${config.colors.primary}
    ForegroundVisited=#${config.colors.tertiary}

    [Colors:Complementary]
    BackgroundAlternate=#${config.colors.inverse_surface}
    BackgroundNormal=#${config.colors.inverse_surface}
    DecorationFocus=#${config.colors.inverse_primary}
    DecorationHover=#${config.colors.inverse_primary}
    ForegroundActive=#${config.colors.inverse_primary}
    ForegroundInactive=#${config.colors.outline}
    ForegroundLink=#${config.colors.inverse_primary}
    ForegroundNegative=#${config.colors.error}
    ForegroundNeutral=#${config.colors.secondary}
    ForegroundNormal=#${config.colors.inverse_on_surface}
    ForegroundPositive=#${config.colors.primary}
    ForegroundVisited=#${config.colors.tertiary}

    [Colors:Header]
    BackgroundAlternate=#${config.colors.surface_variant}
    BackgroundNormal=#${config.colors.surface}
    DecorationFocus=#${config.colors.primary}
    DecorationHover=#${config.colors.primary}
    ForegroundActive=#${config.colors.primary}
    ForegroundInactive=#${config.colors.on_surface_variant}
    ForegroundLink=#${config.colors.primary}
    ForegroundNegative=#${config.colors.error}
    ForegroundNeutral=#${config.colors.secondary}
    ForegroundNormal=#${config.colors.on_surface}
    ForegroundPositive=#${config.colors.primary}
    ForegroundVisited=#${config.colors.tertiary}

    [Colors:Header][Inactive]
    BackgroundAlternate=#${config.colors.surface}
    BackgroundNormal=#${config.colors.surface_variant}
    DecorationFocus=#${config.colors.primary}
    DecorationHover=#${config.colors.primary}
    ForegroundActive=#${config.colors.on_surface}
    ForegroundInactive=#${config.colors.on_surface_variant}
    ForegroundLink=#${config.colors.primary}
    ForegroundNegative=#${config.colors.error}
    ForegroundNeutral=#${config.colors.secondary}
    ForegroundNormal=#${config.colors.on_surface_variant}
    ForegroundPositive=#${config.colors.primary}
    ForegroundVisited=#${config.colors.tertiary}

    [Colors:Selection]
    BackgroundAlternate=#${config.colors.primary_container}
    BackgroundNormal=#${config.colors.primary}
    DecorationFocus=#${config.colors.on_primary}
    DecorationHover=#${config.colors.on_primary}
    ForegroundActive=#${config.colors.on_primary}
    ForegroundInactive=#${config.colors.on_primary_container}
    ForegroundLink=#${config.colors.primary_container}
    ForegroundNegative=#${config.colors.error_container}
    ForegroundNeutral=#${config.colors.secondary_container}
    ForegroundNormal=#${config.colors.on_primary}
    ForegroundPositive=#${config.colors.primary_container}
    ForegroundVisited=#${config.colors.on_primary}

    [Colors:Tooltip]
    BackgroundAlternate=#${config.colors.inverse_surface}
    BackgroundNormal=#${config.colors.inverse_surface}
    DecorationFocus=#${config.colors.inverse_primary}
    DecorationHover=#${config.colors.inverse_primary}
    ForegroundActive=#${config.colors.inverse_primary}
    ForegroundInactive=#${config.colors.outline}
    ForegroundLink=#${config.colors.inverse_primary}
    ForegroundNegative=#${config.colors.error}
    ForegroundNeutral=#${config.colors.secondary}
    ForegroundNormal=#${config.colors.inverse_on_surface}
    ForegroundPositive=#${config.colors.primary}
    ForegroundVisited=#${config.colors.tertiary}

    [Colors:View]
    BackgroundAlternate=#${config.colors.surface}
    BackgroundNormal=#${config.colors.background}
    DecorationFocus=#${config.colors.primary}
    DecorationHover=#${config.colors.primary}
    ForegroundActive=#${config.colors.primary}
    ForegroundInactive=#${config.colors.on_surface_variant}
    ForegroundLink=#${config.colors.primary}
    ForegroundNegative=#${config.colors.error}
    ForegroundNeutral=#${config.colors.secondary}
    ForegroundNormal=#${config.colors.on_background}
    ForegroundPositive=#${config.colors.primary}
    ForegroundVisited=#${config.colors.tertiary}

    [Colors:Window]
    BackgroundAlternate=#${config.colors.surface_variant}
    BackgroundNormal=#${config.colors.surface}
    DecorationFocus=#${config.colors.primary}
    DecorationHover=#${config.colors.primary}
    ForegroundActive=#${config.colors.primary}
    ForegroundInactive=#${config.colors.on_surface_variant}
    ForegroundLink=#${config.colors.primary}
    ForegroundNegative=#${config.colors.error}
    ForegroundNeutral=#${config.colors.secondary}
    ForegroundNormal=#${config.colors.on_surface}
    ForegroundPositive=#${config.colors.primary}
    ForegroundVisited=#${config.colors.tertiary}

    [General]
    ColorScheme=Matugen
    Name=Matugen
    shadeSortColumn=true

    [KDE]
    contrast=4

    [WM]
    activeBackground=#${config.colors.surface}
    activeBlend=#${config.colors.surface}
    activeForeground=#${config.colors.on_surface}
    inactiveBackground=#${config.colors.surface_variant}
    inactiveBlend=#${config.colors.surface_variant}
    inactiveForeground=#${config.colors.on_surface_variant}
  '';

  gtk =
    let
      gtkCss = ''
        @define-color accent_color #${config.colors.primary};
        @define-color accent_fg_color #${config.colors.on_primary};
        @define-color accent_bg_color #${config.colors.primary};
        @define-color window_bg_color #${config.colors.surface};
        @define-color window_fg_color #${config.colors.on_surface};
        @define-color headerbar_bg_color #${config.colors.surface_container};
        @define-color headerbar_fg_color #${config.colors.on_surface};
        @define-color headerbar_border_color @headerbar_bg_color;
        @define-color headerbar_backdrop_color @headerbar_bg_color;
        @define-color headerbar_shade_color @headerbar_bg_color;
        @define-color headerbar_darker_shade_color @headerbar_bg_color;
        @define-color popover_bg_color #${config.colors.surface_container_high};
        @define-color popover_fg_color #${config.colors.on_surface};
        @define-color popover_shade_color @popover_bg_color;
        @define-color view_bg_color #${config.colors.surface};
        @define-color view_fg_color #${config.colors.on_surface};
        @define-color card_bg_color #${config.colors.surface_container_low};
        @define-color card_fg_color #${config.colors.on_surface};
        @define-color card_shade_color @card_bg_color;
        @define-color sidebar_bg_color #${config.colors.surface_container};
        @define-color sidebar_fg_color #${config.colors.on_surface};
        @define-color sidebar_border_color @sidebar_bg_color;
        @define-color sidebar_backdrop_color @sidebar_bg_color;
        @define-color sidebar_shade_color @sidebar_bg_color;
        @define-color secondary_sidebar_bg_color @sidebar_bg_color;
        @define-color secondary_sidebar_fg_color @sidebar_fg_color;
        @define-color secondary_sidebar_border_color @secondary_sidebar_bg_color;
        @define-color secondary_sidebar_backdrop_color @secondary_sidebar_bg_color;
        @define-color secondary_sidebar_shade_color @secondary_sidebar_bg_color;
        @define-color dialog_bg_color #${config.colors.surface_container_high};
        @define-color dialog_fg_color #${config.colors.on_surface};
        @define-color error_bg_color #${config.colors.error};
        @define-color error_fg_color #${config.colors.on_error};
        @define-color scrollbar_outline_color #${config.colors.surface_container_high};
      '';
    in
    {
      gtk3.extraCss = gtkCss;
      gtk4.extraCss = gtkCss;
    };

  xdg.configFile."gtk-3.0/gtk.css".onChange = ''
    gsettings set org.gnome.desktop.interface gtk-theme ""
    gsettings set org.gnome.desktop.interface gtk-theme ${config.gtk.gtk3.theme.name}
  '';

  qt = {
    qt5ctSettings.Appearance = {
      color_scheme_path = "${config.xdg.configHome}/qt5ct/colors/matugen.conf";
      custom_palette = true;
    };
    qt6ctSettings.Appearance = {
      color_scheme_path = "${config.xdg.configHome}/qt6ct/colors/matugen.conf";
      custom_palette = true;
    };
  };

  xdg.configFile."qt5ct/colors/matugen.conf".text = qtctColorSchemeINI;
  xdg.configFile."qt6ct/colors/matugen.conf".text = qtctColorSchemeINI;

  programs.ghostty = {
    settings.theme = "Matugen";
    themes.Matugen = {
      background = "#${config.colors.surface}";
      foreground = "#${config.colors.on_surface}";
      cursor-color = "#${config.colors.on_surface}";
      cursor-text = "#${config.colors.inverse_on_surface}";
      selection-background = "#${config.colors.secondary}";
      selection-foreground = "#${config.colors.on_secondary}";
    };
  };

  programs.fuzzel.settings.colors = {
    background = "${config.colors.surface_container_high}ff";
    text = "${config.colors.on_surface}ff";
    prompt = "${config.colors.primary}ff";
    placeholder = "${config.colors.tertiary}ff";
    input = "${config.colors.on_surface}ff";
    match = "${config.colors.on_surface}ff";
    selection = "${config.colors.secondary}ff";
    selection-text = "${config.colors.on_secondary}ff";
    selection-match = "${config.colors.on_secondary}ff";
    counter = "${config.colors.secondary}ff";
    border = "${config.colors.primary}ff";
  };
}
