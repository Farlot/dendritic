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
      # 1. Your hardware config
      ./_files/hardware-configuration.nix
      
      # 2. Your main host config (combining your old hosts/default.nix & hosts/riggen.nix)
      ./_files/configuration.nix
      
      # 3. Add sops-nix directly here since it's a flake input module
      inputs.sops-nix.nixosModules.sops
    ];
  };
}
