{ ... }: {
  plugins.toggleterm = {
    enable = true;
    # Kein Default-Terminal-Mapping: Tab gehört pi (bindings.nix).
    # shade_terminals=false bleibt, damit pi unschattiert bleibt.
    settings.shade_terminals = false;
  };

  # pi als persistenter Toggle-Terminal (Tasten Tab/3, Normal- UND Visual-Mode).
  # Toggle versteckt nur, die Session läuft weiter; on_exit -> shutdown,
  # damit man nie in einer bash landet. Editor-Kontext laeuft vollautomatisch
  # ueber die user-level Erweiterung ~/.pi/agent/extensions/pi-ide-auto.ts.
  extraConfigLua = ''
    local pi_term = require("toggleterm.terminal").Terminal:new({
      -- fullscreen: pi rendert eigenes Viewport -> Wheel/Scroll geht an pi,
      -- auch waehrend der Agent streamt (kein Follow-Output-Snap mehr)
      cmd = "pi -c --tui-mode fullscreen",
      hidden = true,
      direction = "vertical",
      size = function() return math.floor(vim.o.columns * 0.4) end,
      on_exit = function(term) term:shutdown() end,
    })

    -- Cursor+Selektion pro Fenster erhalten UND sichtbar halten. WICHTIG:
    -- das Einfrieren passiert VOR dem Fensterwechsel (toggle_pi), denn nvim
    -- zieht beim Verlassen im Visual-Modus den Cursor zum Selektionsanfang.
    -- WinLeave darf den eingefrorenen Highlight NICHT loeschen, sondern
    -- nur als Fallback selbst einfrieren (C-w-Wechsel ohne toggle_pi).
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
          table.insert(ids, vim.fn.matchaddpos("Visual", chunk))
          chunk = {}
        end
      end
      if #chunk > 0 then table.insert(ids, vim.fn.matchaddpos("Visual", chunk)) end
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
      -- Selektion einfrieren + fuer pi sichern, BEVOR der Fokus wechselt:
      -- erst hier sind Anker(v) und Cursor ungesnappt, und die Marks '< '>
      -- existieren beim ersten Visual der Session noch nicht (setzt Plugin
      -- erst am Visual-Ende) — deshalb hier explizit setzen und flushen.
      if vis_kind() ~= nil then
        local win = vim.api.nvim_get_current_win()
        freeze_selection(win)
        pcall(function()
          vim.fn.setpos("'<", vim.fn.getpos("v"))
          vim.fn.setpos("'>", vim.fn.getpos("."))
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
