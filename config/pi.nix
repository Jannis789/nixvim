{ pkgs, ... }: {
  # pi headless statt im Terminal: pi.nvim startet die pi-Binary direkt per
  # Job — kein Shell-Terminal im Editor, keine Bash-Reste nach dem Schließen.
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      pname = "pi.nvim";
      version = "unstable";
      src = pkgs.fetchFromGitHub {
        owner = "pablopunk";
        repo = "pi.nvim";
        rev = "fab2a7932a5478e522d609a9fd39a7aac6c0440d";
        hash = "sha256-biRULkVUP8M04GaBNXwPSxOB4EUDOPoaBaYHeEQR36o=";
      };
    })
  ];

  extraConfigLua = ''
    require("pi").setup()
  '';

  keymaps = [
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
  ];
}
