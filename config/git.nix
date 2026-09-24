{ ... }: {
  plugins.gitsigns = {
    enable = true;
  };

  keymaps = [
    {
      key = "<leader>hp";
      action.__raw = "function() require('gitsigns').preview_hunk() end";
      mode = ["n"];
      options.desc = "Git: Hunk-Vorschau";
    }
    {
      key = "<leader>hd";
      action.__raw = "function() require('gitsigns').diffthis() end";
      mode = ["n"];
      options.desc = "Git: Diff gegen Index";
    }
  ];
}
