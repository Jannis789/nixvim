{ ... }: {
  # Zentrale Shortcut-Tabelle — reine Daten, keine Logik. Die Aktionen liegen
  # in den jeweiligen Modulen: _G.toggle_tree (tree.nix), _G.focus_editor
  # (ui.nix), _G.toggle_pi (terminal.nix), _G.git_* (git.nix).
  # Bewusste Ausnahmen: n/m = buffer-lokal in bufferline.nix,
  # <Tab> = toggleterm-Setting in terminal.nix.
  keymaps = [
    ## Scopes: 1 = Tree, 2 = Editor, 3 = pi — nur Normal-Mode
    {
      key = "1";
      action.__raw = ''function() _G.toggle_tree() end'';
      options.desc = "Treeview";
      mode = ["n"];
    }
    {
      key = "2";
      action.__raw = ''function() _G.focus_editor() end'';
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
      action.__raw = "function() _G.git_preview_hunk() end";
      mode = ["n"];
      options.desc = "Git: Hunk-Vorschau";
    }
    {
      key = "<leader>hd";
      action.__raw = "function() _G.git_diff_index() end";
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
