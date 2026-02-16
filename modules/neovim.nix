{ inputs, ... }:

{
  # Expose your custom Neovim setup as a reusable flake module!
  flake.homeManagerModules.neovim = { config, pkgs, lib, ... }: {

    imports = [ inputs.nixvim.homeManagerModules.nixvim ];

    programs.nixvim = {
      enable = true;
      defaultEditor = true;

      # 1. Aesthetics (Tokyo Night)
      colorschemes.tokyonight = {
        enable = true;
        settings.style = "storm"; # Options: storm, night, moon, day
      };

      # 2. Basic Options (The "Vim" stuff)
      opts = {
        number = true;
        relativenumber = true;
        shiftwidth = 2;
        tabstop = 2;
        expandtab = true;
        ignorecase = true;
        smartcase = true;
        mouse = "a";
        clipboard = "unnamedplus"; # Sync with system clipboard
      };

      # 3. Syntax Highlighting (Treesitter)
      plugins.web-devicons.enable = true;
      plugins.treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
        # Nixvim installs parsers automatically, but you can force specific ones:
        # grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        #   nix python json markdown bash
        # ];
      };

      # 4. Status Line (Lualine)
      plugins.lualine = {
        enable = true;
        settings.options.theme = "tokyonight";
      };

      # 5. File Tree (Neo-tree)
      plugins.neo-tree = {
        enable = true;
        settings = {
          enableGitStatus = true;
          enableRefreshOnWrite = true;
          filesystem.followCurrentFile.enabled = true;
          window.position = "left";
        };
      };
      # 6. Git +/- signs changes
      plugins.gitsigns = {
        enable = true;
        settings = {
          signs = {
            add.text = "+";
            change.text = "~";
            delete.text = "-";
            topdelete.text = "‾";
            changedelete.text = "~";
          };
        };
      };

      # 7. Fuzzy Finding (Telescope)
      plugins.telescope = {
        enable = true;
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
        };
      };
      plugins.fugitive.enable = true;
      keymaps = [
        {
          key = "<leader>gs";
          action = "<cmd>Git<CR>";
          mode = "n";
          options = {
            desc = "Git Status";
          };
        }
        {
          mode = "n";
          key = "<leader>e";
          action = "<cmd>Neotree toggle<CR>";
          options.desc = "Toggle Explorer";
        }
      ];

      # 8. AI Agent (Ollama Integration)
      extraPlugins = [ 
        pkgs.vimPlugins.gen-nvim
        pkgs.vimPlugins.vim-visual-multi
      ];

      extraConfigLua = ''
      require('gen').setup({
        model = "deepseek-r1:latest",
        host = "localhost",
        port = "11434",
        display_mode = "float", -- float or split
        show_prompt = true,
        show_model = true,
      })

      -- Keybind to open the AI menu
      vim.keymap.set({'n', 'v'}, '<leader>aa', ':Gen<CR>')
      '';

      # 9. Key Globals
      globals.mapleader = " ";
    };    
  };
}
