{ pkgs, ... }:

{
  colorschemes.catppuccin = {
    enable = true;
    settings = {
      contrastDark = true;
      transparentBg = true;
    };
  };

  plugins = {   
    # --- Copilot Lua (Autocomplete) ---
    copilot-lua = {
      enable = true;
      settings = {
        suggestion = {
          enabled = true;
          auto_trigger = true;
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

        # --- Copilot Chat ---
        {
          name = "CopilotChat.nvim";
          pkg = pkgs.vimPlugins.CopilotChat-nvim;
          dependencies = [ pkgs.vimPlugins.plenary-nvim ];
          event = "VimEnter";
          config = builtins.toJSON ''
            function()
              local ok, copilotchat = pcall(require, "CopilotChat")
              if ok then
                copilotchat.setup({ context = "buffer", show_help = true })
              else
                vim.notify("CopilotChat failed to load", vim.log.levels.WARN)
              end
            end
          '';
        }

        # --- Telescope ---
        {
          name = "telescope.nvim";
          pkg = pkgs.vimPlugins.telescope-nvim;
          dependencies = with pkgs.vimPlugins; [
            plenary-nvim
            telescope-file-browser-nvim
          ];
          event = [ "VimEnter" ];
        }

        # --- nvim-cmp ---
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

        # --- Git ---
        {
          name = "vim-fugitive";
          pkg = pkgs.vimPlugins.vim-fugitive;
          event = [ "VimEnter" ];
        }

        # --- Theme ---
        {
          name = "catppuccin";
          pkg = pkgs.vimPlugins.catppuccin-nvim;
          event = [ "VimEnter" ];
        }

      ];
    };
  };
}
