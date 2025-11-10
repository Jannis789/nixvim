{ pkgs, ... }:

{
  imports = [ ./bufferline.nix ];
  colorschemes.catppuccin = {
    enable = true;
    settings = {
      contrastDark = true;
      transparentBg = true;
    };
  };
  plugins = {
    copilot-lua = {
      enable = true;
      settings = {
        setup = {
          suggestion = {
            enabled = true;
            auto_trigger = true;
          };
          filetypes = {
            markdown = true;
          };
        };
      };
    };
    lualine = {
      enable = true;
      settings = {
        options = {
          theme = "catppuccin";
        };
      };
    };

    lazy = {
      enable = true;
      plugins = [
        {
          name = "copilot.lua";
          pkg = pkgs.vimPlugins.copilot-lua;
          event = "VimEnter";
          config = ''
            require("copilot").setup({
              suggestion = {
                enabled = true,
                auto_trigger = true,
              },
              filetypes = {
                markdown = true,
              }
            })
          '';
        }

        {
          name = "telescope";
          pkg = pkgs.vimPlugins.telescope-nvim;
          dependencies = with pkgs.vimPlugins; [
            plenary-nvim
            telescope-file-browser-nvim
          ];
          event = [ "VimEnter" ];
        }

        {
          name = "nvim-cmp";
          pkg = pkgs.vimPlugins.nvim-cmp;
          dependencies = with pkgs.vimPlugins; [
            cmp-path
            cmp-buffer
            cmp-cmdline
            cmp_luasnip
            cmp-nvim-lsp
          ];
          event = [
            "InsertEnter"
            "CmdlineEnter"
          ];
        }

        {
          name = "vim-fugitive";
          pkg = pkgs.vimPlugins.vim-fugitive;
          event = [ "VimEnter" ];
        }

        {
          name = "catppuccin";
          pkg = pkgs.vimPlugins.catppuccin-nvim;
          event = [ "VimEnter" ];
        }
      ];
    };
  };
}
