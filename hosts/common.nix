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

    boot.loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
    };
    boot.loader.systemd-boot.enable = false;

    time.timeZone = "Europe/Oslo";
    i18n.defaultLocale = "en_US.UTF-8";
    
    services.xserver.enable = true;
    services.displayManager.sddm = {
      enable = true;
      autoNumlock = true;
    };

    services.xserver.xkb = { layout = "no"; variant = ""; };
    console.keyMap = "no";
    services.printing.enable = true;

    # AUDIO
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Noise Canceling
    services.pipewire.extraConfig.pipewire."99-input-denoising" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "node.description" = "Noise Canceling Source";
            "media.name" = "Noise Canceling Source";
            "filter.graph" = {
              nodes = [
                {
                  type = "ladspa";
                  name = "rnnoise";
                  plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                  label = "noise_suppressor_mono";
                  control = { "VAD Threshold (%)" = 85.0; };
                }
              ];
            };
            "capture.props" = {
              "node.name" = "capture.rnnoise_source";
              "node.passive" = true;
              "target.object" = "alsa_input.usb-TC-Helicon_GoXLR-00.HiFi__Headset__source";
            };
            "playback.props" = {
              "node.name" = "rnnoise_source";
              "media.class" = "Audio/Source";
            };
          };
        }
      ];
    };

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
