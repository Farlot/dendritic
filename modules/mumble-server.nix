# modules/mumble-server.nix
{ inputs, ... }:

{
  flake.nixosModules.mumble-server = { config, lib, pkgs, ... }: {
    
    sops.secrets."mumble-server-password" = { };

    sops.templates."murmur.env".content = ''
      MURMUR_PASSWORD=${config.sops.placeholder."mumble-server-password"}
    '';

    services.murmur = {
      enable = true;
      
      # Tell Murmur to read the password from the environment variable we just created!
      password = "$MURMUR_PASSWORD";
      
      environmentFile = config.sops.templates."murmur.env".path;
      
      welcometext = "<br />Welcome to the Tailscale Mumble Server!<br />";
      port = 64738;
      bandwidth = 13000000; 
    };

    # Open the port ONLY on the Tailscale interface
    networking.firewall.interfaces."tailscale0" = {
      allowedTCPPorts = [ config.services.murmur.port ];
      allowedUDPPorts = [ config.services.murmur.port ];
    };

    services.murmur.openFirewall = false;
  };
}
