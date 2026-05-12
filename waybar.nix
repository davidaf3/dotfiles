{
  config,
  lib,
  cpuCores,
  rustScripts,
  ...
}:

{
  programs.waybar = {
    enable = false;
    settings.mainBar = {
      layer = "top";
      position = "top";
      margin-bottom = 0;
      spacing = 0;
      modules-left = [
        "niri/workspaces"
        "cpu"
        "memory"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "tray"
        "network"
        "custom/vpn"
        "pulseaudio"
        "custom/power"
      ];

      "niri/workspaces" = {
        format = "{icon}";
        format-icons.active = "";
        format-icons.default = "";
      };

      clock = {
        tooltip = false;
        format = "{:%A %d  ·  %H:%M}";
        interval = 1;
      };

      tray = {
        icon-size = 16;
        spacing = 10;
      };

      network = {
        format = "";
        format-wifi = "󰤨";
        format-disconnected = "󰲛";
        interval = 5;
        tooltip-format = "{ifname}";
        on-click = "${rustScripts}/bin/networkmenu";
      };

      cpu = {
        interval = 1;
        format =
          let
            icons = builtins.genList (i: "{icon${toString i}}") cpuCores;
          in
          "   ${lib.concatStrings icons}  {usage:>2}%";
        format-icons = [
          "▁"
          "▂"
          "▃"
          "▄"
          "▅"
          "▆"
          "▇"
          "█"
        ];
        on-click = "gnome-system-monitor";
      };

      memory = {
        interval = 30;
        format = "   {used:0.1f} G / {total:0.1f} G";
        tooltip-format = "Memory";
        on-click = "gnome-system-monitor";
      };

      pulseaudio = {
        format = "{icon}  {volume}%";
        format-muted = "";
        format-icons.default = [
          ""
          ""
          ""
        ];
        on-click = "pavucontrol";
      };

      "custom/vpn" = {
        exec = "${rustScripts}/bin/vpnmonitor";
        return-type = "json";
        format = "{}";
        restart-interval = 1;
      };

      "custom/power" = {
        tooltip = false;
        on-click = "${rustScripts}/bin/powermenu";
        format = "";
      };
    };
    style = ''
      * {
        font-family: 'Symbols Nerd Font', sans-serif;
        font-size: 12px;
        min-height: 0;
        padding-right: 0px;
        padding-left: 0px;
        padding-bottom: 0px;
      }

      #waybar {
        background: #${config.colors.surface};
        margin: 0px;
        font-weight: 500;
      }

      #waybar > * {
        margin: 4px 8px;
      }

      #workspaces,
      #cpu,
      #memory {
        background-color: #${config.colors.surface_container};
        padding: 0.3rem 0.7rem;
        margin: 0px;
        border-radius: 8px;
        min-width: 0;
        border: none;
        transition: background-color 0.2s ease-in-out, color 0.2s ease-in-out;
      }

      #workspaces {
        padding: 2px;
        margin-right: 5px;
      }

      #cpu {
        margin-right: 5px;
      }

      #cpu:hover,
      #memory:hover {
        background-color: #${config.colors.surface_container_high};
      }

      #workspaces button {
        color: @on_surface;
        border-radius: 4px;
        padding: 0.3rem 0.6rem;
        background: transparent;
        transition: all 0.2s ease-in-out;
        border: none;
        outline: none;
      }

      #workspaces button.active {
        color: #${config.colors.on_secondary};
        background-color: #${config.colors.secondary};
      }

      #workspaces button.active:hover {
        color: #${config.colors.on_secondary};
        background-color: #${config.colors.secondary};
      }

      #workspaces button:hover {
        color: #${config.colors.on_surface};
        background-color: #${config.colors.surface_container_high};
      }

      #clock {
        background-color: #${config.colors.surface_container};
        padding: 0.3rem 0.7rem;
        margin: 0px;
        border-radius: 8px;
        min-width: 0;
        border: none;
        transition: background-color 0.2s ease-in-out, color 0.2s ease-in-out;
      }

      #clock:hover {
        background-color: #${config.colors.surface_container_high};
      }

      #tray,
      #pulseaudio,
      #network,
      #custom-vpn,
      #custom-power {
        background-color: #${config.colors.surface_container};
        padding: 0.3rem 0.7rem;
        margin: 0px; 
        border-radius: 0;
        box-shadow: none;
        min-width: 0;
        border: none;
        transition: background-color 0.2s ease-in-out, color 0.2s ease-in-out;
      }

      #network:hover,
      #pulseaudio:hover,
      #custom-vpn:hover,
      #custom-power:hover {
        background-color: #${config.colors.surface_container_high};
      }

      #tray {
        border-top-left-radius: 8px;
        border-bottom-left-radius: 8px;
        border-top-right-radius: 8px;
        border-bottom-right-radius: 8px;
        margin-right: 5px;
      }

      #network {
        border-top-left-radius: 8px;
        border-bottom-left-radius: 8px;
      } 

      #custom-power {
        border-top-right-radius: 8px;
        border-bottom-right-radius: 8px;
      }

      #cpu,
      #memory {
        color: @on_surface;
      }

      #clock {
        color: @on_surface;
        font-weight: 500;
      }

      #network,
      #pulseaudio,
      #custom-vpn,
      #custom-power {
        color: @on_surface;
      }
    '';
  };
}
