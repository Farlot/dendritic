{ inputs, ... }:

{
  # This registers the configuration as an official output of your flake!
  flake.nixosModules.common = { config, pkgs, lib, ... }: {
    
    # --- All your standard NixOS config goes inside here ---
    
    imports = [
      # Home manager
      inputs.home-manager.nixosModules.home-manager
      # SOPS Secrets
      inputs.sops-nix.nixosModules.sops
      # NH helper
      inputs.self.nixosModules.nh
    ];

    networking.networkmanager.enable = true;
    networking.firewall.enable = true;
    
    time.timeZone = "Europe/Oslo";
    i18n.defaultLocale = "en_US.UTF-8";

    # Shell
    programs.zsh.enable = true;
    users.users.maw = {
      isNormalUser = true;
      description = "";
      extraGroups = [ "networkmanager" "wheel" "docker" "vboxusers" "gamemode" ];
      shell = pkgs.zsh;
    };

    environment.sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
    };

    nixpkgs.config.allowUnfree = true;
    programs.nix-ld.enable = true;
    programs.git.enable = true;
    environment.systemPackages = [ pkgs.sops ];

    # SOPS Configuration
    sops.defaultSopsFile = ../secrets/secrets.yaml; # Adjust path if needed relative to this file
    sops.defaultSopsFormat = "yaml";
    sops.age.keyFile = "/home/maw/.config/sops/age/keys.txt";

    services.pcscd.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    boot.kernelPackages = pkgs.linuxPackages_latest;

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
      config.common.default = "*";
    };

    system.stateVersion = "24.05";
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
