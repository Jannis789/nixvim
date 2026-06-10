{
  # Entry point for all config modules.
  # Import feature-specific modules here and they gain access
  # to the nixvim module system's extended lib.
  imports = [
    ./colorscheme.nix
    ./statusline.nix
    ./telescope.nix
    ./ui.nix
    ./tree.nix
  ];
}
