{ inputs, ... }:

{
  # Expose your theming engine as a reusable flake module!
  flake.homeManagerModules.stylix = { config, pkgs, lib, ... }: {

    imports = [ inputs.stylix.homeManagerModules.stylix ];

    stylix = {
      enable = true;
      opacity = {
        terminal = 0.8;
      };
      targets = {
        qt.enable = true;
        kde.enable = true;
        gtk.enable = true;
      };
      cursor = {
        package = pkgs.capitaine-cursors;
        name = "capitaine-cursors"; 
        size = 32;
      };
      base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
      polarity = "dark";

      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font Mono";
        };
        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
        };
        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };
      };
    };

  };
}
