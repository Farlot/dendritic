# hosts/riggen/default.nix
{ inputs, ... }:

{
  flake.nixosConfigurations.riggen = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    
    # Pass inputs and any other specialArgs your config needs
    specialArgs = { 
      inherit inputs; 
      username = "maw";
      stable-pkgs = import inputs.stablenixpkgs { system = "x86_64-linux"; };
    };
    
    modules = [
      # Hardware config
      ./_files/hardware-configuration.nix

      # Common for all machines flake
      inputs.self.nixosModules.common
      inputs.self.nixosModules.riggen

      # Home Manager
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "hm-bak";
        home-manager.extraSpecialArgs = { inherit inputs username; };
      }

      # 4. Inject Riggen's Base Home Profile
      inputs.self.nixosModules.riggen-home
    ];
  };
}
