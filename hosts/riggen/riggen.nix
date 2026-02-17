{ inputs, ... }:

{
  flake.nixosModules.riggen = { config, pkgs, lib, ... }: {
    
    networking.hostName = "riggen";

    # ================================================================
    # TODO: Turn these into flake parts one by one and re-enable them
    # ================================================================
    imports = [
      inputs.stable-diffusion-webui-nix.nixosModules.default
      inputs.self.nixosModules.ollama
      inputs.self.nixosModules.wireguardvpn
      inputs.self.nixosModules.tailscale
      inputs.self.nixosModules.backup
      inputs.self.nixosModules.virt
      inputs.self.nixosModules.ckb
      inputs.self.nixosModules.hyprland
    ];

    # ================================================================
    # Hardware & Kernel Settings
    # ================================================================
    boot.kernelParams = [ "kvm.enable_virt_at_load=0" "nvidia-drm.fbdev=0" ];

    hardware.ckb-next.enable = true;
    systemd.services.ckb-next = lib.mkIf config.hardware.ckb-next.enable {
      serviceConfig.ExecStart = lib.mkForce "${config.hardware.ckb-next.package}/bin/ckb-next-daemon --enable-experimental ${lib.optionalString (config.hardware.ckb-next.gid != null) "--gid=${builtins.toString config.hardware.ckb-next.gid}"}";
    };

    fileSystems."/mnt/stuff" = {
      device = "/dev/disk/by-uuid/8198a4fe-fc70-4045-b177-c3e98eacd5cd";
      fsType = "ext4";
    };

    fileSystems."/mnt/nvme0" = {
      device = "/dev/disk/by-uuid/48423cb3-f93f-4db0-8083-9f7cf766a67b";
      fsType = "ext4";
    };
    fileSystems."/mnt/spin" = {
      device = "/dev/disk/by-uuid/94912f39-62b8-43da-9156-70b2accf97a5";
      fsType = "ext4";
    };
    # ================================================================
    # Graphics & Nvidia
    # ================================================================
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      open = false;
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };

    # ================================================================
    # Desktop Environment & Fonts
    # ================================================================
    programs.hyprland = { 
      enable = true; 
      xwayland.enable = true;
    };
    programs.hyprlock.enable = true;

    fonts.packages = with pkgs; [ 
      nerd-fonts.jetbrains-mono 
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];

    # ================================================================
    # Gaming
    # ================================================================
    programs.gamemode.enable = true;
    programs.steam = {
      enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
    };

    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/maw/.steam/root/compatabilitytools.d";
      NIXOS_OZONE_WL = "1";
    };

    # ================================================================
    # Virtualization & Containers
    # ================================================================
    programs.fuse.userAllowOther = true;
    hardware.nvidia-container-toolkit.enable = true;

    virtualisation = {
      oci-containers.backend = "docker";
      docker = {
        enable = true;
        rootless.enable = true;
      };
      virtualbox = {
        host.enable = true;
        guest.enable = true;
      };
    };

    # ================================================================
    # Services & Programs
    # ================================================================
    services.dbus.enable = true;
    services.autorandr.enable = true;
    services.goxlr-utility.enable = true;
    programs.coolercontrol.enable = true;

    nixpkgs.config.permittedInsecurePackages = [ "dotnet-runtime-7.0.20" ];

    environment.systemPackages = with pkgs; [
      openresolv rclone gh
      goxlr-utility ckb-next coolercontrol.coolercontrold
      docker docker-compose runc nvidia-container-toolkit
      protonup-ng
      ollama stable-diffusion-webui.comfy.cuda stable-diffusion-webui.forge.cuda
    ];
  };
}
