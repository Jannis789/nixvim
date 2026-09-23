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

  keymaps = [
    {
      key = "1";
      action.__raw = ''function()
        local cur_buf = vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win())
        if vim.bo[cur_buf].filetype == "NvimTree" then
          vim.cmd.NvimTreeToggle()
        else
          vim.cmd.NvimTreeFocus()
        end
      end'';
      options.desc = "Treeview";
      mode = ["n"];
    }
    {
      key = "2";
      action.__raw = ''function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.bo[buf].filetype
          if ft ~= "NvimTree" and ft ~= "toggleterm" then
            vim.api.nvim_set_current_win(win)
            return
          end
        end
      end'';
      options.desc = "Editor";
      mode = ["n"];
    }
    {
      key = "3";
      action.__raw = ''function() _G.toggle_pi() end'';
      options.desc = "pi (AI)";
      mode = ["n"];
    }
  ];
}