{
  plugins.nvim-tree = {
    enable = true;

    settings = {
      git.enable = true;
      filters.dotfiles = true;

      on_attach.__raw = ''
        function(bufnr)
          local api = require("nvim-tree.api")
          api.map.on_attach.default(bufnr)
          vim.keymap.del("n", "<Tab>", { buffer = bufnr })
          pcall(vim.keymap.del, "n", "n", { buffer = bufnr })
          pcall(vim.keymap.del, "n", "m", { buffer = bufnr })
          vim.keymap.set("n", "/", api.filter.live.start, {
            buffer = bufnr, noremap = true, silent = true, nowait = true,
            desc = "nvim-tree: Filter Tree",
          })
        end
      '';
    };
  };
}
