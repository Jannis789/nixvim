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

  # Scope-übergreifend (alle Modi ausser insert):
  #   <Space>p = Dateisuche, <Space>o = Codesuche
  keymaps = [
    {
      key = "<leader>p";
      action = "<cmd>Telescope find_files<CR>";
      options.desc = "Find Files";
      mode = ["n" "v" "x" "s" "o" "t" "l"];
    }
    {
      key = "<leader>o";
      action = "<cmd>Telescope live_grep<CR>";
      options.desc = "Live Grep";
      mode = ["n" "v" "x" "s" "o" "t" "l"];
    }
  ];

  extraPackages = with pkgs; [ ripgrep fd ];
}
