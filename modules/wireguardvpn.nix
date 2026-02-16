{ inputs, ... }:

{
  # Expose this as a reusable flake module!
  flake.nixosModules.wireguardvpn = { config, pkgs, lib, ... }: {
    
    sops.secrets.wgpriv = {};
    networking = {
      firewall.allowedUDPPorts = [ 51820 ];
      # iproute2.rttablesExtraConfig = ''
      #   200 vpn
      # '';

      # Wireguard client
      firewall.checkReversePath = false;
      wg-quick.interfaces.wg1 = {
        # table = "200";
        address = [ "10.74.75.14/32"
          "fc00:bbbb:bbbb:bb01::b:4b0d/128"
        ];
        dns = [ "10.64.0.1" ];
        privateKeyFile = config.sops.secrets.wgpriv.path;
        peers = [
          {
            publicKey = "jOUZjMq2PWHDzQxu3jPXktYB7EKeFwBzGZx56cTXXQg=";
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            endpoint = "176.125.235.71:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };

  };
}
