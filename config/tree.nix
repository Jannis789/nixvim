{
  plugins.nvim-tree = {
    enable = true;

    settings = {
      git.enable = true;
      filters.dotfiles = true;

      on_attach.__raw = ''
        function(bufnr)
          local api = require("nvim-tree.api")

          -- Default mappings
          api.map.on_attach.default(bufnr)

          -- Remove Tab (Preview), we use it globally to toggle the tree
          vim.keymap.del("n", "<Tab>", { buffer = bufnr })

          -- Space opens/closes folders and files
          vim.keymap.set("n", "<Space>", api.node.open.edit, {
            buffer = bufnr, noremap = true, silent = true, nowait = true,
            desc = "nvim-tree: Open",
          })

          -- / filters tree to show only matching nodes (hides rest)
          vim.keymap.set("n", "/", api.filter.live.start, {
            buffer = bufnr, noremap = true, silent = true, nowait = true,
            desc = "nvim-tree: Filter Tree",
          })
        end
      '';
    };
  };

  # Tab toggles the tree; Enter opens/closes folders (built-in);
  # Space opens/closes in tree; / searches entire tree (live filter)
  keymaps = [
    {
      key = "<Tab>";
      action = "<cmd>NvimTreeToggle<CR>";
      options.desc = "Toggle file tree";
    }
  ];
}
