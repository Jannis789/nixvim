{ ... }: {
  plugins.toggleterm = {
    enable = true;
    # Kein Default-Terminal-Mapping: Tab gehört pi (bindings.nix).
    # shade_terminals=false bleibt, damit pi unschattiert bleibt.
    settings.shade_terminals = false;
  };

  # pi als persistenter Toggle-Terminal (Tasten Tab/3, Normal- UND Visual-Mode).
  # Beim ersten Öffnen verbindet sich pi automatisch mit diesem nvim
  # (tippt /ide + Enter). Toggle versteckt nur, die Session läuft weiter;
  # on_exit -> shutdown, damit man nie in einer bash landet.
  extraConfigLua = ''
    local pi_term
    local auto_connect_pending = true

    pi_term = require("toggleterm.terminal").Terminal:new({
      -- fullscreen: pi rendert eigenes Viewport -> Wheel/Scroll geht an pi,
      -- auch waehrend der Agent streamt (kein Follow-Output-Snap mehr)
      cmd = "pi -c --tui-mode fullscreen",
      hidden = true,
      direction = "vertical",
      size = function() return math.floor(vim.o.columns * 0.4) end,
      -- Auto-Connect: beim frischen pi-Start /ide + Enter eintippen
      on_open = function(term)
        if auto_connect_pending then
          auto_connect_pending = false
          vim.defer_fn(function()
            if pi_term.job_id == nil then return end
            pi_term:send("/ide", false, false)
            vim.defer_fn(function()
              pi_term:send(string.char(13), false, false) -- Enter
            end, 600)
          end, 1500)
        end
      end,
      on_exit = function(term)
        term:shutdown()
        auto_connect_pending = true -- neue Session -> neu verbinden
      end,
    })

    -- Cursor+Selektion pro Fenster erhalten UND sichtbar halten: beim
    -- Verlassen eines Editor-Fensters im Visual-Modus wird die Markierung
    -- als fensterlokales Highlight eingefroren (bleibt sichtbar, waehrend
    -- pi fokussiert ist) und beim Zurueckkehren als echte Visual-Selektion
    -- reaktiviert. Der Selektions-Flush fuer pi passiert in toggle_pi
    -- VOR dem Fokuswechsel (siehe dort).
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

    vim.api.nvim_create_autocmd("WinLeave", {
      group = aug,
      callback = function()
        local win = vim.api.nvim_get_current_win()
        local kind = nil
        if pi_term.bufnr == nil or vim.api.nvim_win_get_buf(win) ~= pi_term.bufnr then
          kind = vis_kind()
        end
        clear_hl(win)
        if kind then
          local snap = { buf = vim.api.nvim_win_get_buf(win), kind = kind }
          -- Sichtbare Markierung einfrieren (ganze Zeilen, max. 8 pro Match)
          local s = vim.fn.getpos("v")
          local e = vim.fn.getpos(".")
          if s[2] > 0 and e[2] > 0 then
            local l1, l2 = math.min(s[2], e[2]), math.max(s[2], e[2])
            local ids, chunk = {}, {}
            for l = l1, l2 do
              table.insert(chunk, { l })
              if #chunk == 8 then
                table.insert(ids, vim.fn.matchaddpos("Visual", chunk))
                chunk = {}
              end
            end
            if #chunk > 0 then table.insert(ids, vim.fn.matchaddpos("Visual", chunk)) end
            snap.hl = ids
          end
          visual_snap[win] = snap
        else
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
        if snap.hl then
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
        local v = vim.fn.getpos("v")
        local c = vim.fn.getpos(".")
        pcall(function()
          vim.fn.setpos("'<", v)
          vim.fn.setpos("'>", c)
          require("pi-ide").flush()
        end)
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
  '';
}
