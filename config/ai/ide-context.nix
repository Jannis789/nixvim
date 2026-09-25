{ pkgs, ... }: {
  # pi-ide-context (nvim-Seite): Autocmds schreiben Cursor/Datei/Selektion
  # debounced nach $XDG_RUNTIME_DIR/pi-ide/<pid>.json; die pi-Seite (installiert
  # via 'pi install npm:pi-ide-context') liest das vor jeder Nachricht und
  # injiziert "### IDE Context". Verbindung: automatisch beim pi-Start
  # (terminal.nix tippt /ide + Enter), sonst /ide manuell.
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
      # Geflickt: solange der Cursor im pi-Terminal (oder einem anderen
      # Non-File-Buffer) steht, NICHT schreiben — sonst überschreibt der
      # Fokuswechsel zur pi-Split die Cursorposition/Selektion des Editors
      # und pi injiziert term://-Müll statt des echten Kontexts.
      postPatch = ''
        sed -i 's|local function write_state()|local function write_state()\n  -- geflickt (nixvim): Non-File-Buffer (pi-Terminal) ueberspringen\n  if vim.bo.buftype ~= "" or vim.api.nvim_buf_get_name(0) == "" then return end|' lua/pi-ide/init.lua
      '';
    })
  ];
}
