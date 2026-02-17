{ inputs, ... }:

{
  # We expose this as a NixOS module so your host's assembly line can easily load it
  flake.nixosModules.riggen-home = { pkgs, lib, username, ... }: {
    
    # This injects the Home Manager scope into the system build
    home-manager.users.${username} = { config, ... }: {
      
      # 1. Import all the pure dotfile modules we just made!
      imports = [
        inputs.self.homeModules.kitty
        inputs.self.homeModules.scripts
        inputs.self.homeModules.yazi
        inputs.self.homeModules.stylix
        inputs.self.homeModules.neovim
        inputs.self.homeModules.desktop
      ];

      # 2. Base identity
      home.stateVersion = "24.05"; # Do not change this unless you read the release notes!
      home.username = "${username}";
      home.homeDirectory = "/home/${username}";

      programs.zoxide = { # terminal navigation tool
        enable = true;
        enableZshIntegration = true;
      };
      programs.fzf.enable = true; # terminal navigation helper for zoxide

      sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        defaultSopsFormat = "yaml";
        age.keyFile = "/home/maw/.config/sops/age/keys.txt"; # Matches your system config

        secrets.git_name = {};
        secrets.git_email = {};
        templates."git-config".content = ''
        [user]
          name = ${config.sops.placeholder.git_name}
          email = ${config.sops.placeholder.git_email}
      '';
      };


      programs.git = {
        enable = true;
        includes = [
          { path = config.sops.templates."git-config".path; }
        ];

        settings = {
          safe.directory = [ "/mnt/stuff/nixos" ];
          url."git@github.com:".insteadOf = "https://github.com/";
        };
      };

      

      # Let Home Manager install and manage itself
      programs.home-manager.enable = true;
    };
  };
}
