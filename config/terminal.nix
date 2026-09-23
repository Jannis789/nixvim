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

  # pi als persistenter Toggle-Terminal (Taste 3): Toggle versteckt nur,
  # die Session läuft weiter. Beendet man pi selbst, schließt das Terminal
  # (on_exit -> shutdown), damit man nie in einer bash landet.
  # -c: beim Neustart die zuletzt aktive Session fortsetzen.
  extraConfigLua = ''
    local pi_term = require("toggleterm.terminal").Terminal:new({
      cmd = "pi -c",
      hidden = true,
      direction = "vertical",
      size = function() return math.floor(vim.o.columns * 0.4) end,
      on_exit = function(term) term:shutdown() end,
    })
    function _G.toggle_pi() pi_term:toggle() end
  '';
}
