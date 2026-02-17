{ inputs, ... }:

{
  # Expose this strictly as a Home Manager module!
  flake.homeModules.rofi = { config, pkgs, lib, ... }: {
    
    stylix.targets.rofi.enable = false;
    programs.rofi = {
      enable = true;
      package = pkgs.rofi;

      plugins = [
        pkgs.rofi-calc
      ];

      cycle = true;
      location = "center";
      terminal = "kitty";

      extraConfig = {
        modi = "drun,calc";
        show-icons = true;
        case-sensitive = false;
        display-drun = " ";
        drun-display-format = "{name}";
      };

      # Theming via Stylix
      theme = let
        inherit (config.lib.formats.rasi) mkLiteral;
      in {
        "*" = {
          font = "${config.stylix.fonts.monospace.name} 11";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "#${config.lib.stylix.colors.base05}FF";
          margin = mkLiteral "0px";
          padding = mkLiteral "0px";
          spacing = mkLiteral "0px";
        };

        "window" = {
          location = mkLiteral "center";
          width = mkLiteral "480";
          border-radius = mkLiteral "8px";
          background-color = mkLiteral "#${config.lib.stylix.colors.base00}D9";
          border = mkLiteral "2px";
          border-color = mkLiteral "#${config.lib.stylix.colors.base0D}FF"; 
        };

        "mainbox" = {
          padding = mkLiteral "12px";
        };

        "inputbar" = {
          background-color = mkLiteral "#${config.lib.stylix.colors.base00}D9";
          border-color = mkLiteral "#${config.lib.stylix.colors.base0D}FF";
          border = mkLiteral "2px";
          border-radius = mkLiteral "8px";
          padding = mkLiteral "8px 16px";
          spacing = mkLiteral "8px";
          children = mkLiteral "[ prompt, entry ]";
        };

        "prompt" = {
          text-color = mkLiteral "#${config.lib.stylix.colors.base0D}FF";
        };

        "entry" = {
          placeholder = "Search";
          placeholder-color = mkLiteral "#${config.lib.stylix.colors.base05}88";
        };

        "listview" = {
          background-color = mkLiteral "transparent";
          margin = mkLiteral "12px 0 0";
          lines = 8;
          columns = 1;
          fixed-height = false;
        };

        "element" = {
          padding = mkLiteral "8px 16px";
          spacing = mkLiteral "8px";
          border-radius = mkLiteral "8px";
          background-color = mkLiteral "transparent";
        };

        "element normal, element alternate" = {
          text-color = mkLiteral "#${config.lib.stylix.colors.base05}FF";
          background-color = mkLiteral "transparent";
        };

        "element selected normal, element selected active" = {
          background-color = mkLiteral "#${config.lib.stylix.colors.base0D}CC";
          text-color = mkLiteral "#${config.lib.stylix.colors.base00}FF";
        };

        "element-text, element-icon" = {
          text-color = mkLiteral "inherit";
        };

        "element-icon" = {
          size = mkLiteral "1em";
          vertical-align = mkLiteral "0.5";
        };
      };
    };

  };
}
