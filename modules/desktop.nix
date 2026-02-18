{ inputs, ... }:

{
  # Expose this as a home-manager module for your hosts to import
  flake.homeModules.desktop = { pkgs, config, lib, ... }: {
    
    home.packages = with pkgs; [
      # --- Communication & Productivity ---
      obsidian
      teams-for-linux
      element-desktop
      discord
      
      # --- Media & Web ---
      spotify
      mpv
      
      # --- Utilities & Graphics ---
      flameshot
      gocryptfs
      hyprshot
      loupe
      gimp
      pavucontrol
      keepassxc
      libnotify
      qdirstat
      
      # --- Gaming (Consider moving to a separate games.nix later) ---
      protontricks
      mangohud
      goverlay
      xivlauncher
      lutris
      itch
      wowup-cf
      prismlauncher
      umu-launcher
      
      # --- Misc Desktop ---
      qbittorrent
      obs-studio
      flatpak
      appimage-run
      btop
      calcurse # Calendar
      ouch # CLI unzipperino
      tldr
    ];

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        v-up = "gocryptfs /mnt/spin/.vault_encrypted /mnt/spin/vault";
        v-down = "fusermount -u /mnt/spin/vault";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "sudo" "docker" ];
        theme = "robbyrussell"; # or "agnoster", "powerlevel10k", etc.
      };
    };

    # --- Desktop Programs ---
    programs.brave = {
      enable = true;
      extensions = [
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
        { id = "oboonakemofpalcgghocfoadofidjkkk"; } # KeePassXC
        { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
        { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # SponsorBlock
        { id = "mmnhjecbajmgkapcinkhdnjabclcnfpg"; } # Reddit Promoted Ad Blocker
        { id = "omoinegiohhgbikclijaniebjpkeopip"; } # Clickbait Remover Youtube
        { id = "gebbhagfogifgggkldgodflihgfeippi"; } # Return YouTube Dislike
        { id = "kbmfpngjjgdllneeigpgjifpgocmfgmb"; } # Reddit Enhancement Suite
        { id = "fchmanciglollaagnijpcagpofejennb"; } # Twitch Channel Point Auto Claimer
        { id = "ammjkodgmmoknidbanneddgankgfejfh"; } # 7TV
      ];
      commandLineArgs = [
        "--disable-features=PasswordManagerOnboarding"
        "--disable-features=AutofillEnableAccountWalletStorage"
      ];
    };

    # --- Desktop Services ---
    services.swaync = {
      enable = true;
      settings = {
        positionX = "right";
        positionY = "top";
        layer = "overlay";
        control-center-layer = "top";
        layer-shell = true;
        cssPriority = "application";
        control-center-margin-top = 0;
        control-center-margin-bottom = 0;
        control-center-margin-right = 0;
        control-center-margin-left = 0;
        notification-2fa-action = true;
        notification-inline-replies = false;
        notification-icon-size = 64;
        notification-body-image-height = 100;
        notification-body-image-width = 200;
      };
    };
  };
}
