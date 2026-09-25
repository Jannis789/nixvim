{ pkgs, ... }: {
  # pi-ide-context (nvim-Seite): Autocmds schreiben Cursor/Datei/Selektion
  # debounced nach $XDG_RUNTIME_DIR/pi-ide/<pid>.json; die pi-Seite (installiert
  # via 'pi install npm:pi-ide-context') liest das vor jeder Nachricht und
  # injiziert "### IDE Context". Verbindung: automatisch beim pi-Start
  # (terminal.nix tippt /ide + Enter).
  #
  # Semantik: Cursor bleibt pro Split nvim-nativ erhalten; der Kontext ist
  # EIN aktiver — das zuletzt fokussierte Editor-Fenster. Fokus im pi-Split
  # friert den Kontext ein (siehe postPatch-Guard), ueberschreibt ihn nicht.
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
      postPatch = ''
        sed -i 's|local function write_state()|local function write_state()\n  -- geflickt (nixvim): Non-File-Buffer (pi-Terminal) ueberspringen\n  if vim.bo.buftype ~= "" or vim.api.nvim_buf_get_name(0) == "" then return end|' lua/pi-ide/init.lua
      '';
    })
  ];

  # :PiCheck — zeigt pro lebendem Editor genau den Kontext, den pi sieht,
  # und raumt States toter Editor-Prozesse auf. Null-sicher: JSON-null wird
  # zu vim.NIL (userdata), daher ueberall type()-Pruefungen statt Wahrheit.
  extraConfigLua = ''
    vim.api.nvim_create_user_command("PiCheck", function()
      local lines = {}
      local ok_plugin = vim.fn.globpath(vim.o.runtimepath, "lua/pi-ide/init.lua") ~= ""
      table.insert(lines, "Plugin geladen:  " .. (ok_plugin and "ja" or "NEIN — nvim komplett beenden und ./result/bin/nvim starten"))
      local d = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/pi-ide"
      local now = os.time()
      local editors = {}
      for _, f in ipairs(vim.fn.glob(d .. "/*.json", false, true)) do
        local pid = tonumber(f:match("(%d+)%.json$"))
        local alive = pid ~= nil and vim.fn.filereadable("/proc/" .. pid .. "/cmdline") == 1
        if pid and not alive then
          os.remove(f) -- toter Editor: State-Leiche aufraeumen
        elseif pid and alive then
          local fh = io.open(f, "r")
          local raw = fh and fh:read("*a") or ""
          if fh then fh:close() end
          local okj, st = pcall(vim.json.decode, raw)
          if not (okj and type(st) == "table") then st = nil end
          if st then
            local ab = st.active_buffer
            if type(ab) ~= "table" then ab = {} end
            local file = type(ab.file) == "string" and ab.file or "?"
            local cur = ab.cursor
            local curline = type(cur) == "table" and tostring(cur.line) or "?"
            local ts = type(st.timestamp) == "number" and st.timestamp or 0
            local age = now - ts
            local zustand = age <= 5 and "live" or ("eingefroren seit " .. age .. " s (normal, solange pi fokussiert ist)")
            local selst = "keine"
            local sel = ab.selection
            if type(sel) == "table" then
              local sa = type(sel.selected_at) == "number" and (now - sel.selected_at) or nil
              if sa ~= nil and sa <= 60 then
                selst = "FRISCH, wird injiziert (" .. sa .. " s)"
              elseif sa ~= nil then
                selst = "verfallen, nur Datei+Cursor (" .. sa .. " s)"
              end
            end
            table.insert(editors, { age = age, line = "  nvim " .. pid .. " -> " .. file .. ":" .. curline .. "  [" .. zustand .. "; Selektion " .. selst .. "]" })
          end
        end
      end
      table.sort(editors, function(a, b) return a.age < b.age end)
      if #editors == 0 then
        table.insert(lines, "Aktive Editoren: KEINE — nvim mit aktuellem Build starten")
      else
        table.insert(lines, "Aktive Editoren (genau das sieht pi pro Nachricht):")
        for _, e in ipairs(editors) do table.insert(lines, e.line) end
      end
      vim.fn.system("pgrep -f 'pi -c --tui-mode fullscreen' >/dev/null")
      table.insert(lines, "pi-Session:      " .. (vim.v.shell_error == 0 and "läuft" or "nicht gestartet — 3 drücken (verbindet automatisch)"))
      vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = ":PiCheck" })
    end, {})
  '';
}
