{ inputs, ... }:

{
  flake.nixosModules.gameserver-factorio = { config, lib, pkgs, ... }: 
  let
    cfg = config.my.gameservers.factorio;
  in {
    
    config = lib.mkIf cfg.enable {
      
      # Generate the secure env file using both secrets
      sops.templates."factorio.env".content = ''
        FACTORIO_SERVER_PASSWORD=${config.sops.placeholder.serverpass}
        RCON_PASSWORD=${config.sops.placeholder.rconpass}
      '';

      virtualisation.oci-containers.containers.factorio = {
        image = "docker.io/factoriotools/factorio";
        
        # Link our custom autostart variable here!
        autoStart = cfg.autoStart; 
        
        ports = [ "34197:34197/udp" "27015:27015/tcp" ];
        volumes = [
          "/mnt/stuff/DockerStuff/factorio:/factorio" 
        ];
        environment = {
          UPDATE_MODS_ON_START = "true";
        };
        environmentFiles = [
          config.sops.templates."factorio.env".path
        ];
      };

      networking.firewall.allowedUDPPorts = [ 34197 ];
      networking.firewall.allowedTCPPorts = [ 27015 ];
    };
    
  };
}
