{ pkgs, ... }: {
  globals.mapleader = " ";

  plugins.telescope = {
    enable = true;
    extensions.file-browser.enable = true;
  };

  # Telescope-Shortcuts (<leader>p/o/fb/fh) zentral in bindings.nix
  extraPackages = with pkgs; [ ripgrep fd ];
}
