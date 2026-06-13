{ pkgs, ... }: {
  globals.mapleader = " ";

  plugins.telescope = {
    enable = true;

    keymaps = {
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

  # Scope-übergreifend (Normal & Visual Mode):
  #   <Space>p = Dateisuche, <Space>o = Codesuche
  keymaps = [
    {
      key = "<leader>p";
      action = "<cmd>Telescope find_files<CR>";
      options.desc = "Find Files";
      mode = [ "n" "v" ];
    }
    {
      key = "<leader>o";
      action = "<cmd>Telescope live_grep<CR>";
      options.desc = "Live Grep";
      mode = [ "n" "v" ];
    }
  ];

  extraPackages = with pkgs; [ ripgrep fd ];
}
