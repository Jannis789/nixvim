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
}
