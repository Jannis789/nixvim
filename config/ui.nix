{ ... }: {
  config = {
    # Maus global: Wheel scrollt Buffers und wird im pi-Terminal an pi durchgereicht
    opts.mouse = "a";

    plugins.nui.enable = true;
    plugins.dressing.enable = true;
    plugins.web-devicons.enable = true;
  };
}
