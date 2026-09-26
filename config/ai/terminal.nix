{ ... }: {
  plugins.toggleterm = {
    enable = true;
    # Kein Default-Terminal-Mapping: Tab gehört pi (bindings.nix).
    # shade_terminals=false bleibt, damit pi unschattiert bleibt.
    settings.shade_terminals = false;
  };

  # pi als persistenter Toggle-Terminal (Tasten Tab/3, Normal- UND Visual-Mode).
  # Toggle versteckt nur, die Session läuft weiter; on_exit -> shutdown,
  # damit man nie in einer bash landet. Editor-Kontext (Live-Widget +
  # Attach) laeuft ueber pi-x-ide — siehe pi-x-ide.nix.
  extraConfigLua = ''
    local pi_term = require("toggleterm.terminal").Terminal:new({
      -- fullscreen: pi rendert eigenes Viewport -> Wheel/Scroll geht an pi,
      -- auch waehrend der Agent streamt (kein Follow-Output-Snap mehr)
      cmd = "pi -c --tui-mode fullscreen",
      hidden = true,
      direction = "vertical",
      size = function() return math.floor(vim.o.columns / 3) end,
      -- toggleterm setzt winfixwidth und ignoriert teils die size-Funktion
      -- (Fenster blieb auf Default 12) — Breite daher hier garantiert setzen.
      on_open = function(term)
        local target = math.floor(vim.o.columns / 3)
        if math.abs(vim.api.nvim_win_get_width(0) - target) > 2 then
          vim.api.nvim_win_set_width(0, target)
        end
      end,
      on_exit = function(term) term:shutdown() end,
    })

    -- Esc im pi-Split: Insert verlassen und direkt in den Editor. Der
    -- Terminal-Normal-Modus ist unbrauchbar (Fullscreen-TUI malt staendig
    -- neu, kein sinnvolles Scrolling) — wer ihn fuer Copy-Ausnahmen braucht,
    -- erreicht ihn manuell mit Strg+\\ Strg+N.
    function _G.exit_pi_to_editor()
      vim.cmd('stopinsert')
      vim.defer_fn(function()
        if _G.focus_editor then _G.focus_editor() end
      end, 10)
    end

    local function vis_kind()
      local b = vim.fn.mode():byte()
      if b == 118 then return "v" end
      if b == 86 then return "V" end
      if b == 22 then return string.char(22) end
      return nil
    end

    local frozen_ids = nil

    local function freeze_selection(win)
      -- PiFrozenSel bekommt die ECHTEN Visual-Farben (matchaddpos mit der
      -- Gruppe "Visual" rendert in unfokussierten Fenstern abweichend/gedimmt).
      -- Alte Chunks zuerst loeschen, sonst summiert sich der Highlight pro
      -- Zyklus.
      if frozen_ids then
        for _, id in ipairs(frozen_ids) do
          pcall(vim.fn.matchdelete, id, win)
        end
        frozen_ids = nil
      end
      local s = vim.fn.getpos("v")
      local e = vim.fn.getpos(".")
      if s[2] == 0 or e[2] == 0 then return nil end
      local vbg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Visual")), "bg#", "gui")
      if vbg == nil or vbg == "" then vbg = "#45475A" end
      local vfg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Visual")), "fg#", "gui")
      local hcmd = "highlight PiFrozenSel guibg=" .. vbg
      if vfg ~= nil and vfg ~= "" then hcmd = hcmd .. " guifg=" .. vfg end
      vim.cmd(hcmd)
      local l1, l2 = math.min(s[2], e[2]), math.max(s[2], e[2])
      local ids, chunk = {}, {}
      for l = l1, l2 do
        table.insert(chunk, { l })
        if #chunk == 8 then
          table.insert(ids, vim.fn.matchaddpos("PiFrozenSel", chunk))
          chunk = {}
        end
      end
      if #chunk > 0 then table.insert(ids, vim.fn.matchaddpos("PiFrozenSel", chunk)) end
      return ids
    end

    -- Beim Verlassen des Editor-Fensters im Visual-Modus: die Markierung
    -- als Highlight einfrieren. Sie BLEIBT stehen, solange pi fokussiert
    -- ist — und auch nach der Rueckkehr, bis eine neue Selektion sie
    -- ersetzt. Kein Restore-in-Visual: ein aktiver Visual-Modus bei der
    -- Rueckkehr wuerde das naechste v nur beenden ("klappt nur einmal").
    vim.api.nvim_create_autocmd("WinLeave", {
      group = vim.api.nvim_create_augroup("PiSplitKeep", { clear = true }),
      callback = function()
        local win = vim.api.nvim_get_current_win()
        if pi_term.bufnr ~= nil and vim.api.nvim_win_get_buf(win) == pi_term.bufnr then return end
        if vis_kind() ~= nil then
          frozen_ids = freeze_selection(win)
        end
      end,
    })

    -- Scope-Logik wie Taste 1: nicht sichtbar -> öffnen; sichtbar, aber
    -- nicht fokussiert -> fokussieren; fokussiert -> verstecken
    -- (Session läuft weiter).
    function _G.toggle_pi()
      -- Selektions-Highlight einfrieren, BEVOR der Fokus wechselt: erst
      -- hier sind Anker(v) und Cursor ungesnappt (WinLeave kaeme zu spaet).
      if vis_kind() ~= nil then
        frozen_ids = freeze_selection(vim.api.nvim_get_current_win())
      end
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if pi_term.bufnr and vim.api.nvim_win_get_buf(win) == pi_term.bufnr then
          if win == vim.api.nvim_get_current_win() then
            pi_term:toggle()
          else
            vim.api.nvim_set_current_win(win)
          end
          return
        end
      end
      pi_term:toggle()
    end

    -- :PiSel — Live-Debug: wie viele Highlight-Chunks sind eingefroren?
    vim.api.nvim_create_user_command("PiSel", function()
      vim.notify("eingefrorene Selektion: " .. (frozen_ids and #frozen_ids or 0) .. " Chunk(s)", vim.log.levels.INFO, { title = ":PiSel" })
    end, {})
  '';
}
