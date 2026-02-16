{ inputs, ... }:

{
  # We expose this as a NixOS module so your host's assembly line can easily load it
  flake.nixosModules.riggen-home = { pkgs, lib, username, ... }: {
    
    # This injects the Home Manager scope into the system build
    home-manager.users.${username} = { config, ... }: {
      
      # 1. Import all the pure dotfile modules we just made!
      imports = [
        inputs.self.homeManagerModules.kitty
        inputs.self.homeManagerModules.rofi
        inputs.self.homeManagerModules.scripts
        inputs.self.homeManagerModules.waybar
        inputs.self.homeManagerModules.yazi
        inputs.self.homeManagerModules.stylix
        inputs.self.homeManagerModules.neovim
      ];

      # 2. Base identity
      home.stateVersion = "24.05"; # Do not change this unless you read the release notes!
      home.username = "${username}";
      home.homeDirectory = "/home/${username}";

      home.packages = with pkgs; [
        obsidian
        flameshot
        git
        teams-for-linux
        spotify
        element-desktop
        protontricks
        mangohud
        goverlay
        xivlauncher
        lutris
        qbittorrent
        tldr
        itch
        wowup-cf
        qdirstat
        discord
        appimage-run
        gocryptfs # encrypt vault
        ouch
        prismlauncher # Minecraft Launcher
        flatpak # package
        umu-launcher # game
        obs-studio # streaming
        ydotool # Autohotkey ish
        rust-stakeholder # rust
        autorandr # monitor
        loupe # image
        keepassxc # password
        btop # process
        nh # game
        gimp # image
        pavucontrol # audio
        hyprshot # screenshot
        libnotify # notification
        kitty # terminal
        calcurse # calendar
        mpv # mediaplayer
      ];      

      programs.zoxide = { # terminal navigation tool
        enable = true;
        enableZshIntegration = true;
      };
      programs.fzf.enable = true; # terminal navigation helper for zoxide


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
          #{ id = "ajopnjidmegmdimjlfnijceegpefgped"; } # BetterTTV
        ];
        commandLineArgs = [
          "--disable-features=PasswordManagerOnboarding"
          "--disable-features=AutofillEnableAccountWalletStorage"
        ];
      };


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

      # ADD SwayNotificationCenter
      services.swaync = {
        enable = true;
        settings = {
          # Optional: Settings to customize the look
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
        # You can also add a style.css here if you want to match your Stylix/Tokyo Night theme
        # style = '' ... ''; 
      };

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

      # Let Home Manager install and manage itself
      programs.home-manager.enable = true;
    };
  };
}
