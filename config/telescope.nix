{ pkgs, ... }:

{
  globals.mapleader = " ";

  plugins.telescope = {
    enable = true;

    keymaps = {
      "<leader>ff" = { # 1
        action = "find_files";
        options.desc = "Find Files";
      };
      "<leader>fg" = { # 1
        action = "live_grep";
        options.desc = "Live Grep";
      };
      "<leader>fb" = {
        action = "buffers";
        options.desc = "Buffers";
      };
      "<leader>fh" = {
        action = "help_tags";
        options.desc = "Help Tags";
      };
    };

    extensions.file-browser.enable = true;
  };

  extraPackages = with pkgs; [ ripgrep fd ];
}
