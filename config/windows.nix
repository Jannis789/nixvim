{ ... }: {
  # Fenstergröße: Ctrl-w a = breiter, Ctrl-w d = schmaler,
  # Shift-Varianten für die Höhe (a/d lassen sich halten -> key repeat)
  keymaps = [
    {
      key = "<C-w>a";
      action = "<C-w>>";
      mode = [ "n" ];
      options.silent = true;
      options.desc = "Split breiter";
    }
    {
      key = "<C-w>d";
      action = "<C-w><";
      mode = [ "n" ];
      options.silent = true;
      options.desc = "Split schmaler";
    }
    {
      key = "<C-w>A";
      action = "<C-w>+";
      mode = [ "n" ];
      options.silent = true;
      options.desc = "Split höher";
    }
    {
      key = "<C-w>D";
      action = "<C-w>-";
      mode = [ "n" ];
      options.silent = true;
      options.desc = "Split flacher";
    }
  ];
}
