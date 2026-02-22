{ inputs, ... }:

{
  flake.nixosModules.wireguardvpn = { config, pkgs, lib, ... }: {
    
    sops.secrets.wgpriv = {};
    networking = {
      firewall.allowedUDPPorts = [ 51820 ];
      firewall.checkReversePath = false;
      
      wg-quick.interfaces.wg1 = {
        address = [ "10.74.75.14/32" "fc00:bbbb:bbbb:bb01::b:4b0d/128" ];
        # Comment out or remove the global DNS to prevent system-wide DNS leaks
        # dns = [ "10.64.0.1" ]; 
        
        privateKeyFile = config.sops.secrets.wgpriv.path;
        peers = [
          {
            publicKey = "jOUZjMq2PWHDzQxu3jPXktYB7EKeFwBzGZx56cTXXQg=";
            # ONLY route Mullvad's internal subnets through the VPN. 
            # This leaves your normal internet traffic entirely untouched!
            allowedIPs = [ "10.64.0.0/10" "fc00:bbbb:bbbb::/48" ];
            endpoint = "176.125.235.71:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };

  };
}
