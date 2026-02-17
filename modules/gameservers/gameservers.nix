{ inputs, ... }:

{
  flake.nixosModules.gameservers = { config, lib, pkgs, ... }: {
    
    # ==========================================
    # 1. UMBRELLA IMPORTS
    # ==========================================
    # Import the individual game definitions here. 
    # Because they are wrapped in `mkIf`, they won't actually 
    # do anything to your system unless you enable them below!
    imports = [
      inputs.self.nixosModules.gameserver-factorio
      # inputs.self.nixosModules.gameserver-minecraft
    ];

    # ==========================================
    # 2. THE SCHEMAS
    # ==========================================
    options.my.gameservers.factorio = {
      enable = lib.mkEnableOption "Factorio Server";
      autoStart = lib.mkOption { type = lib.types.bool; default = false; };
    };

    # options.my.gameservers.minecraft = {
    #   enable = lib.mkEnableOption "Minecraft Server";
    #   autoStart = lib.mkOption { type = lib.types.bool; default = false; };
    # };

    # ==========================================
    # 3. THE CONTROL PANEL
    # ==========================================
    config = {
      
      # -> FLIP YOUR SWITCHES HERE <-
      my.gameservers.factorio = {
        enable = true;      
        autoStart = false;  
      };

      # my.gameservers.minecraft = {
      #   enable = false;
      #   autoStart = false;
      # };

      # Global Server Secrets
      sops.secrets.serverpass = { };
      sops.secrets.rconpass = { };
    };
  };
}
