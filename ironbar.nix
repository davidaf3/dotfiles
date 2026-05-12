{
  config,
  rustScripts,
  ...
}:

{
  programs.ironbar = {
    enable = true;
    config = {
      anchor_to_edges = true;
      position = "top";
      height = 34;
      start = [
        {
          type = "workspaces";
        }
        /*
          {
            type = "sys_info";
            format = [
              "  {cpu_percent:.1}%"
              "  {memory_percent:.1}%"
              "󰋊  {disk_read:.1} / {disk_write:.1} MB/s"
              "󰓢  {net_down:.1} / {net_up:.1} Mbps"
            ];
          }
        */
      ];
      center = [
        {
          type = "clock";
          format = "<b>%a %d %b</b>  %H:%M";
        }
      ];
      end = [
        {
          type = "tray";
          icon_size = 12;
        }
        {
          type = "network_manager";
          icon_size = 12;
          types_blacklist = [
            "loopback"
            "dummy"
          ];
        }
        {
          type = "volume";
          format = "{icon}";
          mute_format = "{icon}";
          truncate_popup = {
            mode = "end";
            max_length = 20;
          };
          profiles =
            let
              defaultIcons = {
                muted = "";
                mic_volume = "";
                mic_muted = "";
              };
            in
            {
              low = {
                when = 50;
                icons = defaultIcons // {
                  volume = "";
                };

              };
              medium = {
                when = 66;
                icons = defaultIcons // {
                  volume = "";
                };
              };
              high = {
                when = 100;
                icons = defaultIcons // {
                  volume = "";
                };
              };
            };
        }
        {
          bar = [
            {
              label = "";
              on_click = "!${rustScripts}/bin/powermenu";
              name = "power";
              type = "button";
            }
          ];
          class = "power";
          type = "custom";
        }
      ];
    };
    style = ''
      * {
        font-family: 'Symbols Nerd Font', sans-serif;
        font-size: 12px;
        font-weight: 500;
      }

      button {
        min-height: 0;
        min-width: 16px;
      }

      #bar {
        background: #${config.colors.surface};
      }

      .sysinfo .item, .clock {
        background-color: #${config.colors.surface_container};
        margin: 4px 0;
        padding: 3px 12px;
        border-radius: 16px;
      }

      .workspaces .item, .clock, .tray .item picture, .tray .item popover modelbutton:hover, .volume, .popup-volume .device-selector > button, .power button {
        transition: background-color .3s cubic-bezier(.2,0,0,1);
      }

      .workspaces .item:hover, .clock:hover, .tray .item picture:hover, .volume:hover, .power button:hover {
        background-color: mix(#${config.colors.surface_container}, #${config.colors.on_surface}, 0.08);
      }

      .workspaces {
        margin: 0 10px;
      }

      .workspaces .item {
        margin: 4px 1px;
        padding: 3px 10px;
        background-color: #${config.colors.surface_container};
        color: #${config.colors.on_surface_variant};
        border-radius: 8px;
        transition: border-radius .3s cubic-bezier(.2,0,0,1), background-color .3s cubic-bezier(.2,0,0,1);
      }

      .workspaces .item:first-child {
        border-radius: 16px 8px 8px 16px;
        margin-left: 0;
      }

      .workspaces .item:last-child {
        border-radius: 8px 16px 16px 8px;
        margin-right: 0;
      }

      .workspaces .item.focused {
        background-color: #${config.colors.primary};
        color: #${config.colors.on_primary};
        border-radius: 16px;
      }

      .workspaces .item.focused:hover {
        background-color: mix(#${config.colors.primary}, #${config.colors.on_primary}, 0.08);
      }

      .clock popover > contents, .volume > popover > contents {
        background-color: #${config.colors.surface_container_high};
        color: #${config.colors.on_surface};
        padding: 12px;
        border-radius: 16px;
      }

      .popup-clock .calendar-clock {
        font-size: 24px;
        padding: 0 0 8px;
      }

      .popup-clock calendar {
        background-color: #${config.colors.surface_container_high};
        border: 0;
        border-top: 1px solid #${config.colors.outline_variant};
        padding-top: 10px;
      }

      .popup-clock calendar > header {
        color: #${config.colors.on_surface_variant};
        border: 0;
      }

      .popup-clock calendar .day-number {
        min-width: 20px;
        min-height: 30px;
        padding: 0;
        border-radius: 16px;
      }

      .popup-clock calendar .day-number.today {
        box-shadow: inset 0 0 0 1px #${config.colors.primary};
      }

      .popup-clock calendar .day-number.other-month {
        color: alpha(#${config.colors.on_surface_variant}, 0.38);
      }

      .popup-clock calendar .day-number:selected {
        background-color: #${config.colors.primary};
        color: #${config.colors.on_primary};
      }

      .popup-clock calendar .day-number:focus {
        outline-width: 0;
      }

      .popup-clock calendar .day-number:hover, tray .item popover modelbutton:hover, .popup-volume .device-selector > button:hover {
        background-color: mix(#${config.colors.surface_container_high}, #${config.colors.on_surface}, 0.08);
      }

      .popup-clock calendar .day-number:selected:hover {
        background-color: mix(#${config.colors.primary}, #${config.colors.on_primary}, 0.08);
      }

      #end {
        background-color: #${config.colors.surface_container};
        margin: 4px 10px 4px 0;
        padding: 4px 8px;
        border-radius: 16px;
      }

      #end > revealer:not(:last-child) > *:not(.tray):not(.network_manager) {
        margin-right: 5px;
      }

      .tray .item, .network_manager > box {
        margin-right: 5px;
      }

      .tray .item, .volume, .power button {
        background-color: #${config.colors.surface_container};
        padding: 0;
        border-radius: 0;
      }

      .tray .item picture, .network_manager .icon.image, .volume .sink, .volume .source, .power button > label {
        min-width: 24px;
        min-height: 18px;
      }

      .tray .item:last-child {
        border-right: 1px solid #${config.colors.outline_variant};
      }

      .tray .item:last-child > box {
        border-right: 5px solid #${config.colors.surface_container};
      }

      .tray .item picture, .volume, .power button {
        border-radius: 16px;
      }

      .tray popover arrow {
        background: transparent;
        border: 0;
      }

      .tray popover {
        margin-top: -7px;
      }

      .popup-volume.horizontal > box {
        min-width: 180px;
      }

      .popup-volume.horizontal > box.device-box {
        padding-right: 10px;
        border-right: 1px solid #${config.colors.outline_variant};
      }

      .popup-volume .device-selector > button {
        padding: 8px;
        background-color: #${config.colors.surface_container_high};
        border-radius: 4px;
      }

      .popup-volume .device-selector > button:checked {
        background-color: mix(#${config.colors.surface_container_high}, #${config.colors.on_surface}, 0.1);
      }

      .slider {
        padding: 8px;
      }

      .slider trough {
        background-color: #${config.colors.secondary_container};
      }

      .slider trough:hover {
        background-color: mix(#${config.colors.secondary_container}, #${config.colors.on_secondary_container}, 0.08);
      }

      .slider trough:active {
        background-color: mix(#${config.colors.secondary_container}, #${config.colors.on_secondary_container}, 0.1);
      }

      .slider slider, .slider highlight {
        background-color: #${config.colors.primary};
      }

      .slider slider:hover, slider highlight:hover {
        background-color: mix(#${config.colors.primary}, #${config.colors.on_primary}, 0.08);
      }

      .slider slider:active, slider highlight:active {
        background-color: mix(#${config.colors.primary}, #${config.colors.on_primary}, 0.1);
      }

      .slider.horizontal slider {
        min-height: 10px;
        min-width: 10px;
      }

      .slider.horizontal trough {
        min-height: 4px;
      }

      dropdown popover > contents {
        background-color: #${config.colors.surface_container_low};
        color: #${config.colors.on_surface};
        border-radius: 12px;
        transition: border-radius .3s cubic-bezier(.2,0,0,1), background-color .3s cubic-bezier(.2,0,0,1);
      }

      dropdown popover > contents listview {
        padding: 4px;
      }

      dropdown popover > contents listview row {
        margin: 0;
        padding: 8px;
        border-radius: 8px;
      }

      dropdown popover > contents listview row:selected {
        background-color: #${config.colors.tertiary_container};
        color: #${config.colors.on_tertiary_container};
        border-radius: 8px;
      }

      dropdown popover > contents listview row:selected:hover {
        background-color: mix(#${config.colors.tertiary_container}, #${config.colors.on_tertiary_container}, 0.08);
        border-radius: 8px;
      }

      .btn-mute {
        background-color: #${config.colors.secondary_container};
        color: #${config.colors.on_secondary_container};
        margin: 0 60px;
        min-height: 16px;
        border-radius: 16px;
        transition: border-radius .3s cubic-bezier(.2,0,0,1), background-color .3s cubic-bezier(.2,0,0,1);
      }

      .btn-mute:checked {
        background-color: #${config.colors.secondary};
        color: #${config.colors.on_secondary};
        border-radius: 8px;
      }

      .btn-mute:hover {
        background-color: mix(#${config.colors.secondary_container}, #${config.colors.on_secondary_container}, 0.08);
      }

      .btn-mute:checked:hover {
        background-color: mix(#${config.colors.secondary}, #${config.colors.on_secondary}, 0.08);
      }

      .popup-volume .app-box .title {
        padding: 8px;
      }

      .popup-volume .app-box > :not(:last-child) {
        margin-bottom: 5px;
      }
    '';
  };
}
