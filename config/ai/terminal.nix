{ ... }: {
  plugins.toggleterm = {
    enable = true;
    settings.shade_terminals = false;
  };

  # pi als persistenter Toggle (Tab/3, Normal+Visual). Verstecken hält die
  # Session am Leben; on_exit räumt auf (keine bash-Reste). Kontext: pi-x-ide.nix.
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

    local function vis_kind(mode)
      local m = mode or vim.fn.mode()
      local b = m:byte()
      if b == 118 then return "v" end
      if b == 86 then return "V" end
      if b == 22 then return string.char(22) end
      return nil
    end

    -- Eingefrorene Selektion: beim Verlassen des Editor-Fensters im
    -- Visual-Modus wird die Markierung zeichengenau als Highlight
    -- eingefroren (bleibt sichtbar, solange pi fokussiert ist). Beim
    -- WinEnter zurueck in dieses Fenster wird sie als AKTIVER Visual-
    -- Modus restauriert (nativ: Esc/Cursorbewegung beendet sie).
    local frozen = nil

    local function clear_frozen()
      if frozen and frozen.win and vim.api.nvim_win_is_valid(frozen.win) then
        for _, id in ipairs(frozen.ids or {}) do
          pcall(vim.fn.matchdelete, id, frozen.win)
        end
      end
      frozen = nil
    end

    local function freeze_selection(win, kind, sl, sc, el, ec)
      if kind == nil or sl == 0 or el == 0 then return nil end
      if pi_term.bufnr ~= nil and vim.api.nvim_win_get_buf(win) == pi_term.bufnr then return nil end
      if frozen and frozen.win and vim.api.nvim_win_is_valid(frozen.win) then
        for _, id in ipairs(frozen.ids or {}) do
          pcall(vim.fn.matchdelete, id, frozen.win)
        end
      end
      local vbg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Visual")), "bg#", "gui")
      if vbg == nil or vbg == "" then vbg = "#45475A" end
      local vfg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Visual")), "fg#", "gui")
      local hcmd = "highlight PiFrozenSel guibg=" .. vbg
      if vfg ~= nil and vfg ~= "" then hcmd = hcmd .. " guifg=" .. vfg end
      vim.cmd(hcmd)
      local l1, l2 = math.min(sl, el), math.max(sl, el)
      local ids, chunk = {}, {}
      if kind == "v" then
        if sl == el then
          table.insert(chunk, { sl, sc, ec - sc + 1 })
        else
          table.insert(chunk, { sl, sc, #vim.fn.getline(sl) - sc + 1 })
          for l = sl + 1, el - 1 do table.insert(chunk, { l }) end
          table.insert(chunk, { el, 1, ec })
        end
      else
        for l = sl, el do table.insert(chunk, { l }) end
      end
      for _, pos in ipairs(chunk) do
        table.insert(ids, vim.fn.matchaddpos("PiFrozenSel", { pos }))
      end
      frozen = { win = win, buf = vim.api.nvim_win_get_buf(win), kind = kind, l1 = sl, l2 = el, ids = ids }
      return frozen
    end

    -- C-w-Fallback: Fensterwechsel direkt aus dem Visual-Modus — live aus
    -- Anker(v)/Cursor einfrieren (der 3-Pfad friert in toggle_pi ein).
    vim.api.nvim_create_autocmd("WinLeave", {
      group = vim.api.nvim_create_augroup("PiSplitKeep", { clear = true }),
      callback = function()
        local win = vim.api.nvim_get_current_win()
        if pi_term.bufnr ~= nil and vim.api.nvim_win_get_buf(win) == pi_term.bufnr then return end
        local kind = vis_kind()
        if kind == nil then return end
        local sl = vim.fn.line("v")
        local el = vim.fn.line(".")
        local sc = vim.fn.col("v")
        freeze_selection(win, kind, sl, sc, el, 1)
      end,
    })

    -- Rueckkehr in ein Fenster mit eingefrorener Selektion: als aktiven
    -- Visual-Modus restaurieren (nativ beendbar, gv wiederholt).
    vim.api.nvim_create_autocmd("WinEnter", {
      group = vim.api.nvim_create_augroup("PiSplitKeep", { clear = true }),
      callback = function()
        if frozen == nil then return end
        local win = vim.api.nvim_get_current_win()
        if win ~= frozen.win then return end
        if vim.api.nvim_win_get_buf(win) ~= frozen.buf then return end
        if vis_kind() ~= nil then return end -- schon in einem Visual-Modus
        local snap = frozen
        clear_frozen() -- die restaurierte echte Selektion uebernimmt
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
      -- Selektions-Highlight einfrieren, BEVOR der Fokus wechselt: erst
      -- hier sind Anker(v) und Cursor ungesnappt (WinLeave kaeme zu spaet).
      if vis_kind() ~= nil then
        local s = vim.fn.getpos("v")
        local e = vim.fn.getpos(".")
        freeze_selection(vim.api.nvim_get_current_win(), vis_kind(), s[2], s[3], e[2], e[3])
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

    -- :PiSel — Live-Debug: eingefrorene Selektion sichtbar?
    vim.api.nvim_create_user_command("PiSel", function()
      if frozen then
        vim.notify("eingefroren: Zeile " .. frozen.l1 .. "-" .. frozen.l2 .. " (" .. #frozen.ids .. " Chunks)", vim.log.levels.INFO, { title = ":PiSel" })
      else
        vim.notify("keine eingefrorene Selektion", vim.log.levels.INFO, { title = ":PiSel" })
      end
    end, {})
  '';
}
