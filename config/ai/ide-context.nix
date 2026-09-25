{ pkgs, ... }: {
  # pi-ide-context (nvim-Seite): Autocmds schreiben Cursor/Datei/Selektion
  # debounced nach /tmp/pi-ide/<pid>.json; die pi-Seite (installiert via
  # 'pi install npm:pi-ide-context') liest das vor jeder Nachricht und
  # injiziert "### IDE Context". Verbindung pro Session: /ide im pi-Split.
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      pname = "pi-ide-context";
      version = "unstable";
      src = pkgs.fetchFromGitHub {
        owner = "Andy8647";
        repo = "pi-ide-context";
        rev = "c23cecc59bebf4622eb6f3075b8ef6eb28beb67c";
        hash = "sha256-V+JSVNddT5NEXSkS4U5Brz9zDRHErwd2ZgFMGRfLXo8=";
      };
    })
  ];
}
