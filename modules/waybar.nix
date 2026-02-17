{ inputs, ... }:

{
  # Expose this strictly as a Home Manager module!
  flake.homeModules.waybar = { config, pkgs, lib, ... }: {
    
    programs.waybar = {
      enable = true;

      # Declarative JSON Config
      settings = [{
        layer = "top";
        position = "top";
        output = "DP-1"; # Matches your original config
        modules-left = [ "hyprland/workspaces" "custom/mc" "custom/tomestone" "custom/streamtrack" ];
        modules-center = [ "clock" "custom/work" ];
        modules-right = [ "tray" "custom/ping" "custom/notification" "cpu" "memory" "pulseaudio" ];

        "tray" = {
          icon-size = 16;
          spacing = 10;
        };

        "clock" = {
          # Format: ShortDay, DD/MM, Week: WeekNum | HH:MM:SS
          format = "{:%a, %d/%m, Week: %V | %H:%M:%S}";
          # Tooltip: Keep full date info or calendar
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          interval = 1;
          on-click = "kitty --hold calcurse";

          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{:%V}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
        };

        "custom/notification" = {
          tooltip = false;
          format = "{icon}";
          format-icons = {
            notification = "<span foreground='red'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='red'><sup></sup></span>";
            dnd-none = "";
            inhibited-notification = "<span foreground='red'><sup></sup></span>";
            inhibited-none = "";
            dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
            dnd-inhibited-none = "";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          escape = true;
        };

        "custom/work" = {
          format = "{}";
          return-type = "json";
          exec = "waybar-work-countdown";
          interval = 60; # Update every minute
        };

        "custom/tomestone" = {
          format = "{}";
          return-type = "json";
          interval = 300;
          exec = "tomestone-check";
          on-click = "xdg-open https://tomestone.gg/character/39794582/tiny-kaoi/activity";
        };

        "custom/streamtrack" = {
          format = "{}";
          return-type = "json";
          exec = "waybar-streamtrack";
          interval = 300; # Check every 5 minutes to avoid rate limiting
          tooltip = true;
        };

        "custom/ping" = {
          format = "{}";
          return-type = "json";
          exec = "waybar-ping"; # Using your new Nix-managed script
          interval = 10;
          on-click = "kitty --hold ping 8.8.8.8";
        };

        "custom/mc" = {
          format = "{}";
          return-type = "json";
          exec = "waybar-mc"; # The script we created above
          interval = 60;      # Check every 60 seconds
          on-click = "kitty --hold mcstatus localhost:25565 status";
        };

        "cpu" = {
          format = " {usage}%";
          on-click = "kitty --hold btop";
        };

        "memory" = {
          format = " {used} GB";
          on-click = "kitty --hold btop";
        };

        "pulseaudio" = {
          format = "󰓃 {volume}%";
          format-muted = " muted";
          on-click = "pavucontrol";
          # on-click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        };

        "hyprland/workspaces" = {
          all-outputs = true;
          disable-scroll = true;
        };
      }];

      # Declarative CSS
      style = ''
      * {
        font-family: JetBrainsMono Nerd Font, monospace;
        font-size: 14px;
        font-weight: bold;
        border: 1px;
        padding: 0;
        margin: 0;
        color: #fc2d5e;
      }

      window#waybar {
        background-color: rgba(40, 40, 40, 0.95);
        border-bottom: 3px solid #fc2d5e;
      }

      #workspaces button {
        margin: 0 4px;
        padding: 2px 6px;
        background-color: transparent;
      }

      #workspaces button.active { color: #02a332; }
      #workspaces button.urgent { color: #00a130; }

      #cpu, #memory, #pulseaudio, #tray, #custom-ping { 
        margin-right: 15px; 
      }

      /* Your new color-coded Ping classes */
      #custom-ping.good { color: #02a332; }
      #custom-ping.average { color: #e0af68; }
      #custom-ping.poor { color: #fc2d5e; }
      #custom-ping.critical { 
        color: #ffffff; 
        background-color: #ff0000; 
        border-radius: 4px;
        padding: 0 5px;
      }
      #custom-mc { margin-right: 15px; }
      #custom-mc.good { color: #02a332; }
      #custom-mc.critical { color: #fc2d5e; }
      #custom-tomestone {
        padding: 0 10px;
        color: #c0caf5; /* Default text color */
      }

      #custom-tomestone.cleared {
        color: #9ece6a; /* Green for clears */
      }

      #custom-tomestone.wipe {
        color: #f7768e; /* Red/Pink for wipes */
      }

      #custom-tomestone.error {
        color: #ff9e64; /* Orange for errors */
      }
      #custom-streamtrack.online {
        color: #9ece6a; /* Tokyo Night Green */
      }
      #custom-streamtrack.offline {
        color: #565f89; /* Tokyo Night Dark Gray */
      }
      '';
    };
  };
}
