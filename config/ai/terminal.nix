{ ... }: {
  plugins.toggleterm = {
    enable = true;
    # Kein Default-Terminal-Mapping: Tab gehört pi (bindings.nix).
    # shade_terminals=false bleibt, damit pi unschattiert bleibt.
    settings.shade_terminals = false;
  };

  # pi als persistenter Toggle-Terminal (Tasten Tab/3, Normal- UND Visual-Mode).
  # Toggle versteckt nur, die Session läuft weiter; on_exit -> shutdown,
  # damit man nie in einer bash landet. Editor-Kontext (Live-Widget + Attach)
  # laeuft ueber pi-x-ide — siehe pi-x-ide.nix.
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

    -- Cursor+Selektion pro Fenster erhalten UND sichtbar halten. WICHTIG:
    -- das Einfrieren muss VOR dem Fensterwechsel passieren (toggle_pi), denn
    -- nvim zieht beim Verlassen eines Fensters im Visual-Modus den Cursor
    -- zum Selektionsanfang — ein WinLeave-Snapshot allein wuerde nur die
    -- erste Zeile einfrieren. WinLeave ist nur Fallback fuer C-w-Wechsel.
    local visual_snap = {}
    local aug = vim.api.nvim_create_augroup("PiSplitKeep", { clear = true })

    local function vis_kind()
      local b = vim.fn.mode():byte()
      if b == 118 then return "v" end
      if b == 86 then return "V" end
      if b == 22 then return string.char(22) end
      return nil
    end

    local function clear_hl(win)
      local snap = visual_snap[win]
      if snap and snap.hl then
        for _, id in ipairs(snap.hl) do
          pcall(vim.fn.matchdelete, id, win)
        end
      end
    end

    -- Eingefrorene Selektion knallgelb (Search), damit sie im Editor-Split
    -- unuebersehbar sichtbar bleibt, solange pi fokussiert ist.
    vim.cmd("highlight default link PiFrozenSel Search")

    local function freeze_selection(win)
      local s = vim.fn.getpos("v")
      local e = vim.fn.getpos(".")
      if s[2] == 0 or e[2] == 0 then return nil end
      clear_hl(win)
      local snap = { buf = vim.api.nvim_win_get_buf(win), kind = vis_kind() }
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
      snap.hl = ids
      visual_snap[win] = snap
      return snap
    end

    vim.api.nvim_create_autocmd("WinLeave", {
      group = aug,
      callback = function()
        local win = vim.api.nvim_get_current_win()
        local kind = nil
        if pi_term.bufnr == nil or vim.api.nvim_win_get_buf(win) ~= pi_term.bufnr then
          kind = vis_kind()
        end
        if kind then
          if visual_snap[win] == nil then
            freeze_selection(win) -- Fallback: Cursor evtl. schon gesnappt
          end
          -- Snapshot existiert schon (toggle_pi): Highlight bleibt stehen!
        else
          clear_hl(win)
          visual_snap[win] = nil
        end
      end,
    })

    vim.api.nvim_create_autocmd("WinEnter", {
      group = aug,
      callback = function()
        local win = vim.api.nvim_get_current_win()
        local snap = visual_snap[win]
        if snap == nil then return end
        visual_snap[win] = nil
        if snap.hl and type(snap.hl) == "table" then
          for _, id in ipairs(snap.hl) do
            pcall(vim.fn.matchdelete, id, win)
          end
        end
        if vis_kind() ~= nil then return end -- schon in einem Visual-Modus
        vim.defer_fn(function()
          if not vim.api.nvim_win_is_valid(win) then return end
          if vim.api.nvim_win_get_buf(win) ~= snap.buf then return end
          vim.api.nvim_win_call(win, function()
            vim.cmd("normal! `<")
            vim.cmd("normal! " .. snap.kind .. "`>")
          end)
        end, 20)
      end,
    })

    -- Scope-Logik wie Taste 1: nicht sichtbar -> öffnen; sichtbar, aber
    -- nicht fokussiert -> fokussieren; fokussiert -> verstecken
    -- (Session läuft weiter).
    function _G.toggle_pi()
      -- Selektion fuer pi sichern, BEVOR der Fokus wechselt: im pi-Fenster
      -- blockiert der ide-context-Guard das Schreiben, und ein Fensterwechsel
      -- zieht den Cursor zum Selektionsanfang. Die Marks '< '> existieren
      -- erst nach dem Visual-Ende — beim ersten Visual der Session sind sie
      -- unset, deshalb hier explizit aus Anker(v)+Cursor setzen.
      if vis_kind() ~= nil then
        freeze_selection(vim.api.nvim_get_current_win())
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

    -- :PiSel — Live-Debug: was ist pro Fenster eingefroren, wie viele
    -- Matches sind im Editor-Fenster? (Fehlt der Befehl: alter Build.)
    vim.api.nvim_create_user_command("PiSel", function()
      local out = {}
      for win, snap in pairs(visual_snap) do
        table.insert(out, ("fenster %d: kind=%s buf=%d matches=%s"):format(win, tostring(snap.kind), snap.buf or -1, snap.hl and #snap.hl or 0))
      end
      if #out == 0 then table.insert(out, "keine Snapshots") end
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        local ft = vim.bo[vim.api.nvim_win_get_buf(w)].filetype
        if ft ~= "toggleterm" and ft ~= "NvimTree" then
          table.insert(out, "editor-fenster " .. w .. ": matches=" .. #vim.fn.getmatches(w))
        end
      end
      vim.notify(table.concat(out, "\n"), vim.log.levels.INFO, { title = ":PiSel" })
    end, {})
  '';
}
