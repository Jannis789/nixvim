{
  # Entry point: die Subfolder bringen jeweils ihr eigenes default.nix mit —
  # neue Datei = in den passenden Ordner + eine Import-Zeile dort.
  # bindings.nix ist bereichsübergreifend und bleibt deshalb oben.
  imports = [
    ./bindings.nix
    ./appearance
    ./editing
    ./ai
    ./lsp
  ];
}
