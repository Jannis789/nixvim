{ ... }: {
  # Fenstergröße: Ctrl-w a = breiter, Ctrl-w d = schmaler,
  # Shift-Varianten für die Höhe (a/d lassen sich halten -> key repeat)
  keymaps = [
    {
      key = "<C-w>a";
      action = "<C-w>>";
      mode = [ "n" "t" ];
      options.silent = true;
      options.desc = "Split breiter";
    }
    {
      key = "<C-w>d";
      action = "<C-w><";
      mode = [ "n" "t" ];
      options.silent = true;
      options.desc = "Split schmaler";
    }
    {
      key = "<C-w>A";
      action = "<C-w>+";
      mode = [ "n" "t" ];
      options.silent = true;
      options.desc = "Split höher";
    }
    {
      key = "<C-w>D";
      action = "<C-w>-";
      mode = [ "n" "t" ];
      options.silent = true;
      options.desc = "Split flacher";
    }
    {
      key = "<A-Right>";
      action = "<C-w>5>";
      mode = [ "n" "t" ];
      options.silent = true;
      options.desc = "Split breiter";
    }
    {
      key = "<A-Left>";
      action = "<C-w>5<";
      mode = [ "n" "t" ];
      options.silent = true;
      options.desc = "Split schmaler";
    }
    {
      key = "<A-Up>";
      action = "<C-w>5+";
      mode = [ "n" "t" ];
      options.silent = true;
      options.desc = "Split höher";
    }
    {
      key = "<A-Down>";
      action = "<C-w>5-";
      mode = [ "n" "t" ];
      options.silent = true;
      options.desc = "Split flacher";
    }
  ];
}
