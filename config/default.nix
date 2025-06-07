{ pkgs, ... }:

{
  # Import all your configuration modules here
  imports = [ ./bufferline.nix ];
  colorschemes.catppuccin = {
    enable = true;
    settings = {
      contrastDark = true;
      transparentBg = true;
    };
  };
  plugins = {

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
