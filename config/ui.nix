{ ... }: {
  config = {
    # Maus global: Wheel scrollt Buffers und wird im pi-Terminal an pi durchgereicht
    opts.mouse = "a";

    plugins.nui.enable = true;
    plugins.dressing.enable = true;
    plugins.web-devicons.enable = true;

    # Taste 2 (bindings.nix): erstes Editor-Fenster fokussieren
    extraConfigLua = ''
      function _G.focus_editor()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.bo[buf].filetype
          if ft ~= "NvimTree" and ft ~= "toggleterm" then
            vim.api.nvim_set_current_win(win)
            return
          end
        end
      end
    '';
  };
}
