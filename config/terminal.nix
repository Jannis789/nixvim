{ ... }: {
  plugins.toggleterm = {
    enable = true;

    settings = {
      size = 20;
      open_mapping.__raw = ''"<Tab>"'';
      direction = "horizontal";
      shade_terminals = false;
    };
  };

  # ESC im Terminal -> Normal-Mode (sonst landet sie beim Job, z.B. pi)
  keymaps = [
    {
      key = "<Esc>";
      action = "<C-\\><C-n>";
      mode = ["t"];
      options.silent = true;
      options.desc = "Terminal -> Normal";
    }
  ];

  # pi als persistenter Toggle-Terminal (Taste 3): Toggle versteckt nur,
  # die Session läuft weiter. Beendet man pi selbst, schließt das Terminal
  # (on_exit -> shutdown), damit man nie in einer bash landet.
  # -c: beim Neustart die zuletzt aktive Session fortsetzen.
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
    -- Scope-Logik wie Taste 1: nicht sichtbar -> öffnen; sichtbar, aber
    -- nicht fokussiert -> nur fokussieren (Scope-Wechsel); fokussiert ->
    -- verstecken (Session läuft weiter).
    function _G.toggle_pi()
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
