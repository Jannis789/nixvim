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

  # Taste 1 (bindings.nix): Tree zu, wenn fokussiert — sonst öffnen+fokussieren
  extraConfigLua = ''
    function _G.toggle_tree()
      local cur_buf = vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win())
      if vim.bo[cur_buf].filetype == "NvimTree" then
        vim.cmd.NvimTreeToggle()
      else
        vim.cmd.NvimTreeFocus()
      end
    end
  '';
}
