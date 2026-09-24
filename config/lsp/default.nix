{
  # Language Server. Nixvim installiert die Server-Pakete automatisch.
  # Wächst das hier, pro Sprache eine eigene Datei in diesem Ordner
  # (z.B. ./nix.nix) und in imports eintragen.
  plugins.lsp = {
    enable = true;
    servers = {
      nil_ls.enable = true;   # Nix
      lua_ls.enable = true;   # Lua (nvim-Konfig, pi-Extensions)
      html.enable = true;     # hub/index.html
      cssls.enable = true;
      jsonls.enable = true;
      ts_ls.enable = true;    # JS/TS/JSX/TSX (auch React)
      vala_ls.enable = true;  # Vala
      jdtls.enable = true;    # Java
      pyright.enable = true;  # Python
      sqls.enable = true;     # SQL
    };
  };
}
