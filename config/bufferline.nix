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

  # n/m: Bufferline-Tab-Navigation via BufEnter-Autocmd
  # Verwendet vim.schedule + Lua-Funktionen.
  # Wichtig: bufferline.cycle() braucht einen Buffer der in bufferlines
  # Tab-Liste ist. Plugin-Buffer (NvimTree, Agentic, toggleterm) sind gefiltert.
  # Daher: vor cycle() kurz zu einem Editor-Buffer wechseln, dann cyclen.
  extraConfigLua = ''
    local bufgroup = vim.api.nvim_create_augroup("BufferlineTabKeys", { clear = true })

    local function focus_editor()
      local ft = vim.bo[vim.api.nvim_get_current_buf()].filetype
      local plugin_ft = { NvimTree = true, toggleterm = true }
      if not plugin_ft[ft] and not (ft and ft:match("^Agentic")) then
        return -- schon im Editor
      end
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local bft = vim.bo[buf].filetype
        if bft ~= "NvimTree" and not (bft and bft:match("^Agentic")) and bft ~= "toggleterm" then
          vim.api.nvim_set_current_win(win)
          return
        end
      end
    end

    local function tab_prev()
      focus_editor()
      require("bufferline").cycle(-1)
    end

    local function tab_next()
      focus_editor()
      require("bufferline").cycle(1)
    end

    vim.api.nvim_create_autocmd("BufEnter", {
      group = bufgroup,
      pattern = "*",
      callback = function()
        vim.schedule(function()
          local buf = vim.api.nvim_get_current_buf()
          if not vim.api.nvim_buf_is_valid(buf) then return end
          for _, mode in ipairs({"n", "v", "x", "s", "o"}) do
            pcall(vim.keymap.set, mode, "n", tab_prev,
              { buffer = buf, silent = true, desc = "Tab nach links" })
            pcall(vim.keymap.set, mode, "m", tab_next,
              { buffer = buf, silent = true, desc = "Tab nach rechts" })
          end
        end)
      end,
    })
  '';

  keymaps = [
    {
      key = "<leader>bd";
      action = ":bdelete<CR>";
      options.desc = "Delete buffer";
      mode = ["n" "v" "x" "s" "o" "t" "l"];
    }
    {
      key = "<leader>bp";
      action = ":BufferLinePick<CR>";
      options.desc = "Pick buffer";
      mode = ["n" "v"];
    }
  ];
}
