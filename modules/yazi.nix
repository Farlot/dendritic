{ inputs, ... }:

{
  # Expose Yazi strictly as a Home Manager module!
  flake.homeManagerModules.yazi = { config, pkgs, lib, ... }: {
    
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      
      keymap = {
        manager.prepend_keymap = [
          {
            on = [ "g" "n" ];
            # Native Home Manager pathing!
            run = "cd ${config.home.homeDirectory}/dendritic";
            desc = "Go to nix config";
          }
        ];
      };
      
      settings = {
        manager = {
          show_hidden = true;
          sort_by = "natural";
          sort_dir_first = true;
          linemode = "none";
          shell = "${pkgs.zsh}/bin/zsh";
        };
        
        opener = {
          edit = [ { run = ''nvim "$@"''; block = true; for = "unix"; desc = "Edit with Neovim"; } ];
          view = [ { run = ''loupe "$@"''; orphan = true; for = "unix"; desc = "View Image"; } ];
          play = [ { run = ''mpv "$@"''; orphan = true; for = "unix"; desc = "Play Video"; } ];
        };

        open = {
          prepend_rules = [
            { mime = "text/*"; use = [ "edit" ]; }
            { mime = "image/*"; use = [ "view" ]; }
            { mime = "video/*"; use = [ "play" ]; }
            { name = "*.nix"; use = [ "edit" ]; }
          ];
        };
        
        preview = {
          max_width = 2560;
          max_height = 1440;
          image_filter = "lanczos3";
        };
      };
    };

    home.sessionVariables = {
      YAZI_LOG = "debug";
      EDITOR = "nvim";
      VISUAL = "nvim";
      SHELL = "${pkgs.zsh}/bin/zsh";
      PATH = "$PATH:/run/current-system/sw/bin";
    };

    home.packages = with pkgs; [
      p7zip unrar gnutar
      ffmpegthumbnailer poppler imagemagick ghostscript
      fd ripgrep zoxide loupe mpv
    ];
  };
}
