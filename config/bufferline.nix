{
  plugins.bufferline = {
    enable = true;
    settings = {
      options = {
        separator_style = "thin";
        diagnostics = "nvim_lsp";
      };
    };
  };

  keymaps = [
    {
      key = "n";
      action = ":BufferLineCyclePrev<CR>";
      options.desc = "Buffer left";
    }
    {
      key = "m";
      action = ":BufferLineCycleNext<CR>";
      options.desc = "Buffer right";
    }
    {
      key = "<leader>bd";
      action = ":bdelete<CR>";
      options.desc = "Delete buffer";
    }
    {
      key = "<leader>bp";
      action = ":BufferLinePick<CR>";
      options.desc = "Pick buffer";
    }
  ];
}
