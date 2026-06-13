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
      mode = ["n" "v" "x" "s" "o" "t" "l"];
    }
    {
      key = "2";
      action.__raw = ''function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.bo[buf].filetype
          if ft ~= "NvimTree" and not ft:match("^Agentic") and ft ~= "toggleterm" then
            vim.api.nvim_set_current_win(win)
            return
          end
        end
      end'';
      options.desc = "Editor";
      mode = ["n" "v" "x" "s" "o" "t" "l"];
    }
    {
      key = "3";
      action.__raw = ''function()
        local function ft(win)
          local buf = vim.api.nvim_win_get_buf(win)
          local ok, f = pcall(function() return vim.bo[buf].filetype end)
          return (ok and f) or ""
        end
        local function visible(win)
          local cfg = vim.api.nvim_win_get_config(win)
          return cfg and cfg.relative == ""
        end

        local cur = vim.api.nvim_get_current_win()

        -- (1) Auf Chat? → close (Session bleibt)
        if ft(cur):match("^Agentic") and visible(cur) then
          require("agentic").close()
          return
        end

        -- (2) Sichtbaren Chat suchen → fokussieren
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if ft(win) == "AgenticInput" and visible(win) then
            vim.api.nvim_set_current_win(win)
            vim.cmd("startinsert!")
            return
          end
        end
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if ft(win):match("^Agentic") and visible(win) then
            vim.api.nvim_set_current_win(win)
            return
          end
        end

        -- (3) Nichts sichtbar → show() direkt auf der Session aufrufen
        local SessionRegistry = require("agentic.session_registry")
        local session = SessionRegistry.get_session_for_tab_page(nil)
        if session then
          session.widget:show({ focus_prompt = true })
        else
          require("agentic").open()
        end
      end'';
      options.desc = "AI-Chat";
      mode = ["n" "v" "x" "s" "o" "t" "l"];
    }
  ];
}