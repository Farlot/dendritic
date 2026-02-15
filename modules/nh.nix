{ inputs, ... }:

{
  flake.nixosModules.nh = { config, pkgs, lib, username, ... }: {
    programs.nh = {
      enable = true;
      
      # Quality of Life: Automated Cleanup!
      # This runs garbage collection but guarantees you keep the last 3 generations
      # and anything newer than 4 days, so you can always roll back safely.
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 8";
      };
      
      # Setting this automatically exports the $FLAKE environment variable
      # so you can just type `nh os switch` from anywhere!
      flake = "/home/${username}/dendritic"; 
    };
  };
}
