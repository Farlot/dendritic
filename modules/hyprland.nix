{ inputs, ... }:

{
  flake.nixosModules.hyprland = { config, pkgs, lib, username, ... }: {
    
    # ================================================================
    # 1. NIXOS SYSTEM CONFIGURATION
    # ================================================================
    # Enables the compositor, Cachix binary caches, and PAM integrations
    programs.hyprland = { 
      enable = true; 
      xwayland.enable = true;
    };
    
    # Enable the screen locker at the system level
    programs.hyprlock.enable = true;

    # You could also add Hyprland-specific system packages here!
    # environment.systemPackages = [ pkgs.wl-clipboard pkgs.hyprpaper ];

    # ================================================================
    # 2. HOME MANAGER USER CONFIGURATION
    # ================================================================
    home-manager.users.${username} = {
      
      imports = [
        inputs.self.homeModules.waybar
        inputs.self.homeModules.rofi
      ];
      # Enable Hyprland through Home Manager
      wayland.windowManager.hyprland = {
        enable = true;

        # Optional: If you want to use the package from your flake inputs/system
        # package = pkgs.hyprland; 

        # This creates the hyprland.conf for you
        settings = {

          ################
          ### MONITORS ###
          ################
          monitor = [
            "DP-2, 3360x1440@100, 0x0, 1"
            "DP-1, 1760x1440@100, 3360x0, 1"
          ];

          ###################
          ### MY PROGRAMS ###
          ###################
          "$terminal" = "kitty";
          "$fileManager" = "kitty --title yazi-float -e yazi";
          "$menu" = "rofi";

          #################
          ### AUTOSTART ###
          #################
          exec-once = [
            "[workspace 2 silent] brave"
            "[workspace 2 silent] vesktop"
            "[workspace 8 silent] ckb-next"
            "[workspace 8 silent] keepassxc"
            "[workspace 6 silent] teams-for-linux"
            "waybar"
            "hyprshot"
            "wl-clip-persist --clipboard regular"
            "clipse -listen"
            "xrandr --output DP-2 --primary" # Note: xrandr might not work well in pure Wayland, consider using wlr-randr or hyprctl
          ];

          #############################
          ### ENVIRONMENT VARIABLES ###
          #############################
          env = [
            # "XCURSOR_SIZE,24"
            # "HYPRCURSOR_SIZE,24"
          ];

          #####################
          ### LOOK AND FEEL ###
          #####################
          general = {
            gaps_in = 1;
            gaps_out = 5;
            border_size = 3;

            # You can use Nix variable interpolation here!
            #"col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
            #"col.inactive_border" = "rgba(595959aa)";

            resize_on_border = false;
            allow_tearing = false;
            layout = "master";
          };

          decoration = {
            rounding = 0;
            rounding_power = 2;
            active_opacity = 1.0;
            inactive_opacity = 1.0;

            shadow = {
              enabled = true;
              range = 4;
              render_power = 3;
              #color = "rgba(1a1a1aee)";
            };

            blur = {
              enabled = true;
              size = 3;
              passes = 1;
              vibrancy = 0.1696;
            };
          };

          animations = {
            enabled = true;
            bezier = [
              "easeOutQuint,0.23,1,0.32,1"
              "easeInOutCubic,0.65,0.05,0.36,1"
              "linear,0,0,1,1"
              "almostLinear,0.5,0.5,0.75,1.0"
              "quick,0.15,0,0.1,1"
            ];
            animation = [
              "global, 1, 10, default"
              "border, 1, 5.39, easeOutQuint"
              "windows, 1, 4.79, easeOutQuint"
              "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
              "windowsOut, 1, 1.49, linear, popin 87%"
              "fadeIn, 1, 1.73, almostLinear"
              "fadeOut, 1, 1.46, almostLinear"
              "fade, 1, 3.03, quick"
              "layers, 1, 3.81, easeOutQuint"
              "layersIn, 1, 4, easeOutQuint, fade"
              "layersOut, 1, 1.5, linear, fade"
              "fadeLayersIn, 1, 1.79, almostLinear"
              "fadeLayersOut, 1, 1.39, almostLinear"
              "workspaces, 1, 1.94, almostLinear, fade"
              "workspacesIn, 1, 1.21, almostLinear, fade"
              "workspacesOut, 1, 1.94, almostLinear, fade"
            ];
          };

          master = {
            new_status = "master";
            orientation = "right";
          };

          misc = {
            force_default_wallpaper = -1;
            disable_hyprland_logo = true;
          };

          input = {
            numlock_by_default = true;
            kb_layout = "no";
            follow_mouse = 1;
            sensitivity = 0;
            touchpad = {
              natural_scroll = false;
            };
          };

          # Device specific config
          device = {
            name = "epic-mouse-v1";
            sensitivity = -0.5;
          };

          ####################
          ### KEYBINDINGS ###
          ####################
          "$mainMod" = "SUPER";

          bind = [
            "$mainMod, W, exec, brave -show"
            "$mainMod, A, exec, rofi -show drun"
            "ALT, Space, exec, rofi -show calc -modi calc -no-show-match -no-sort"
            "$mainMod, F, fullscreen"
            "$mainMod CTRL, F, exec, hyprshot -m region -o ~/Pictures/Screenshots"
            "$mainMod, R, exec, kitty -e nvim"
            "$mainMod, Q, exec, $terminal"
            "$mainMod, C, killactive,"
            "$mainMod, M, exit,"
            "$mainMod, E, exec, kitty --title yazi-float -e yazi"
            "$mainMod, V, togglefloating,"
            "$mainMod, R, exec, $menu"

            # Move focus with mainMod + arrow keys
            "$mainMod, left, movefocus, l"
            "$mainMod, right, movefocus, r"
            "$mainMod, up, movefocus, u"
            "$mainMod, down, movefocus, d"

            # Move focus with mainMod + vim keys
            "$mainMod, h, movefocus, l"
            "$mainMod, l, movefocus, r"
            "$mainMod, k, movefocus, u"
            "$mainMod, j, movefocus, d"

            # Optional: Move the actual windows around with mainMod + SHIFT + vim/arrow keys
            "$mainMod SHIFT, left, movewindow, l"
            "$mainMod SHIFT, right, movewindow, r"
            "$mainMod SHIFT, up, movewindow, u"
            "$mainMod SHIFT, down, movewindow, d"

            "$mainMod SHIFT, h, movewindow, l"
            "$mainMod SHIFT, l, movewindow, r"
            "$mainMod SHIFT, k, movewindow, u"
            "$mainMod SHIFT, j, movewindow, d"

            # Focus movement
            "$mainMod, Tab, cyclenext, visible"
            "$mainMod SHIFT, Tab, cyclenext, visible prev"
            "$mainMod, Space, layoutmsg, swapwithmaster auto"

            # Special workspace
            "$mainMod, S, togglespecialworkspace, magic"
            "$mainMod, 1, workspace, 1"
            "$mainMod, 2, workspace, 2"
            "$mainMod, 3, workspace, 3"
            "$mainMod, 4, workspace, 4"
            "$mainMod, 5, workspace, 5"
            "$mainMod, 6, workspace, 6"
            "$mainMod, 7, workspace, 7"
            "$mainMod, 8, workspace, 8"
            "$mainMod, 9, workspace, 9"
            "$mainMod, 0, workspace, 10"
            "$mainMod SHIFT, 1, movetoworkspace, 1"
            "$mainMod SHIFT, 2, movetoworkspace, 2"
            "$mainMod SHIFT, 3, movetoworkspace, 3"
            "$mainMod SHIFT, 4, movetoworkspace, 4"
            "$mainMod SHIFT, 5, movetoworkspace, 5"
            "$mainMod SHIFT, 6, movetoworkspace, 6"
            "$mainMod SHIFT, 7, movetoworkspace, 7"
            "$mainMod SHIFT, 8, movetoworkspace, 8"
            "$mainMod SHIFT, 9, movetoworkspace, 9"
            "$mainMod SHIFT, 0, movetoworkspace, 10"
          ];

          # Mouse binds
          bindm = [
            "$mainMod, mouse:272, movewindow"
            "$mainMod, mouse:273, resizewindow"
          ];

          # Multimedia keys
          bindel = [
            ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
            ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
            ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
            ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
          ];

          ##############################
          ### WINDOWS AND WORKSPACES ###
          ##############################
          workspace = [
            "w[tv1], gapsout:0, gapsin:0"
            "f[1], gapsout:0, gapsin:0"
            "1, name:gaming, monitor:DP-2, default:true"
            "2, name:Disctube, monitor:DP-1, layoutopt:orientation:top"
            "3, name:browse, monitor:DP-2"
            "4, name:steam, monitor:DP-2"
            "5, name:phone, monitor:DP-1"
            "6, name:teams, monitor:DP-1"
            "8, name:VboxPass, monitor:DP-2"
            "9, name:WorkPC, monitor:DP-2"
          ];

        };
      };
      # more stuff here

      # Hyprpaper
      services.hyprpaper = {
        enable = true;
        settings = {
          splash = false;
          wallpaper = [
            {
              monitor = "DP-2";
              path = "/home/maw/.config/wallpaper/od_nvim.png";
              fit_mode = "cover";
            }
            {
              monitor = "DP-1";
              path = "/home/maw/.config/wallpaper/od_nvim.png";
              fit_mode = "cover";
            }
          ];
        };
      };

      # Hyprlock
      programs.hyprlock = {
        enable = true;
        settings = {
          general = {
            hide_cursor = true;
          };

          # background = [
          #   {
          #     monitor = "DP-2";
          #     path = "/home/maw/hypr/lock.png";
          #     blur_passes = 1;
          #   }
          # ];


          label = [
            {
              monitor = "";
              text = "$TIME";
              font_size = 50;
              font_family = "Monospace";
              position = "-0, -300";
              halign = "center";
              valign = "top";
            }
            {
              monitor = "";
              text = "cmd[update:60000] date +\"%A, %d %B %Y\"";
              font_size = 15;
              font_family = "Monospace";
              position = "-0, -400";
              halign = "center";
              valign = "top";
            }
          ];
        };
      };

      services.hypridle = {
        enable = true;
        settings = {
          general = {
            # Avoid starting multiple instances
            lock_cmd = "pidof hyprlock || hyprlock";
            ignore_dbus_inhibit = true;
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
          };

          listener = [
            {
              timeout = 300; # 5 minutes in seconds
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
          ];
        };
      };      
    };
  };
}
