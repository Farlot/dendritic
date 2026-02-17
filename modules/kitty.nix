{ inputs, ... }:

{
  # Expose Kitty strictly as a Home Manager module!
  flake.homeModules.kitty = { config, pkgs, lib, ... }: {
    
    programs.kitty = {
      enable = true;
      # font = {
      #   name = "JetBrainsMono Nerd Font";
      #   size = 12; 
      # };

      shellIntegration.enableZshIntegration = true;
    };
    
  };
}
