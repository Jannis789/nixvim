{ ... }: {
  # Zentrale Shortcut-Datei. Bewusste Ausnahmen:
  #   n/m (Tab-Wechsel)  = buffer-lokal via Autocmd in bufferline.nix
  #   <Tab> (toggleterm) = Plugin-Setting in terminal.nix
  # Taste 3 ruft _G.toggle_pi aus terminal.nix auf.
  keymaps = [
    ## Scopes: 1 = Tree, 2 = Editor, 3 = pi — nur Normal-Mode
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

    ## pi headless (pi.nvim)
    {
      key = "<leader>d";
      action = "<cmd>PiAsk<CR>";
      mode = [ "n" ];
      options = {
        desc = "pi: Prompt mit Buffer als Kontext";
        silent = true;
      };
    }
    {
      key = "<leader>d";
      action = "<cmd>PiAskSelection<CR>";
      mode = [ "v" ];
      options = {
        desc = "pi: Prompt mit Selektion als Kontext";
        silent = true;
      };
    }
    {
      # Headless gibt es kein Terminal-Strg-C — Abbruch nur über diesen Befehl
      key = "<leader>D";
      action = "<cmd>PiCancel<CR>";
      mode = [ "n" ];
      options = {
        desc = "pi: laufende Anfrage abbrechen";
        silent = true;
      };
    }

    ## Git (gitsigns)
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

    ## Fenstergröße (auch im Terminal-Mode; Alt-Pfeile halten zum Streamen)
    {
      key = "<C-w>a"; action = "<C-w>>"; mode = [ "n" "t" ];
      options.silent = true; options.desc = "Split breiter";
    }
    {
      key = "<C-w>d"; action = "<C-w><"; mode = [ "n" "t" ];
      options.silent = true; options.desc = "Split schmaler";
    }
    {
      key = "<C-w>A"; action = "<C-w>+"; mode = [ "n" "t" ];
      options.silent = true; options.desc = "Split höher";
    }
    {
      key = "<C-w>D"; action = "<C-w>-"; mode = [ "n" "t" ];
      options.silent = true; options.desc = "Split flacher";
    }
    {
      key = "<A-Right>"; action = "<C-w>5<"; mode = [ "n" "t" ];
      options.silent = true; options.desc = "Split schmaler";
    }
    {
      key = "<A-Left>"; action = "<C-w>5>"; mode = [ "n" "t" ];
      options.silent = true; options.desc = "Split breiter";
    }
    {
      key = "<A-Up>"; action = "<C-w>5+"; mode = [ "n" "t" ];
      options.silent = true; options.desc = "Split höher";
    }
    {
      key = "<A-Down>"; action = "<C-w>5-"; mode = [ "n" "t" ];
      options.silent = true; options.desc = "Split flacher";
    }

    ## ESC im Terminal -> Normal-Mode (sonst landet sie beim Job, z.B. pi)
    {
      key = "<Esc>";
      action = "<C-\\><C-n>";
      mode = ["t"];
      options.silent = true;
      options.desc = "Terminal -> Normal";
    }

    ## Telescope (Leader = Leertaste)
    {
      key = "<leader>p"; action = "<cmd>Telescope find_files<CR>";
      mode = [ "n" "v" ]; options.desc = "Find Files";
    }
    {
      key = "<leader>o"; action = "<cmd>Telescope live_grep<CR>";
      mode = [ "n" "v" ]; options.desc = "Live Grep";
    }
    {
      key = "<leader>fb"; action = "<cmd>Telescope buffers<CR>";
      mode = ["n"]; options.desc = "Buffers";
    }
    {
      key = "<leader>fh"; action = "<cmd>Telescope help_tags<CR>";
      mode = ["n"]; options.desc = "Help Tags";
    }
  ];
}
