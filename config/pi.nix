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
}
