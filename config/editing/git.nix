{ ... }: {
  plugins.gitsigns = {
    enable = true;
  };

  # <leader>hp / <leader>hd (bindings.nix)
  extraConfigLua = ''
    function _G.git_preview_hunk()
      require('gitsigns').preview_hunk()
    end
    function _G.git_diff_index()
      require('gitsigns').diffthis()
    end
  '';
}
