{ pkgs, ... }: {
  # pi-ide-context (nvim-Seite): Autocmds schreiben Cursor/Datei/Selektion
  # debounced nach $XDG_RUNTIME_DIR/pi-ide/<pid>.json; die pi-Seite (installiert
  # via 'pi install npm:pi-ide-context') liest das vor jeder Nachricht und
  # injiziert "### IDE Context". Verbindung: automatisch beim pi-Start
  # (terminal.nix tippt /ide + Enter).
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
      # Fokuswechsel zur pi-Split die Cursorposition/Selektion des Editors.
      postPatch = ''
        sed -i 's|local function write_state()|local function write_state()\n  -- geflickt (nixvim): Non-File-Buffer (pi-Terminal) ueberspringen\n  if vim.bo.buftype ~= "" or vim.api.nvim_buf_get_name(0) == "" then return end|' lua/pi-ide/init.lua
      '';
    })
  ];

  # :PiCheck — macht die stumme Kette nvim -> Statefile -> pi sichtbar.
  # Existiert dieser Befehl in einer nvim-Instanz NICHT, laeuft diese
  # Instanz auf einem alten Build (nix build + vollstaendiger Neustart noetig).
  extraConfigLua = ''
    vim.api.nvim_create_user_command("PiCheck", function()
      local lines = {}
      local ok_plugin = vim.fn.globpath(vim.o.runtimepath, "lua/pi-ide/init.lua") ~= ""
      table.insert(lines, "Plugin geladen:  " .. (ok_plugin and "ja" or "NEIN"))
      local d = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/pi-ide"
      local newest, age = nil, math.huge
      for _, f in ipairs(vim.fn.glob(d .. "/*.json", false, true)) do
        local st = vim.uv.fs_stat(f)
        if st then
          local a = os.time() - st.mtime.sec
          if a < age then age, newest = a, f end
        end
      end
      if newest then
        table.insert(lines, ("State-Datei:     ja, %d s alt"):format(age))
        table.insert(lines, "nvim-Seite:      " .. (age <= 15 and "OK — schreibt lebendig" or "veraltet — Cursor im Editor bewegen"))
      else
        table.insert(lines, "State-Datei:     NEIN — kein nvim mit Plugin aktiv")
      end
      vim.fn.system("pgrep -f 'pi -c --tui-mode fullscreen' >/dev/null")
      local pi_run = vim.v.shell_error == 0
      table.insert(lines, "pi-Session:      " .. (pi_run and "läuft" or "nicht gestartet — 3 drücken (verbindet automatisch)"))
      vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = ":PiCheck" })
    end, { desc = "pi-ide-context Kette prüfen" })
  '';
}
