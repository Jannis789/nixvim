{ pkgs, ... }: {
  # pi-x-ide (nvim-Seite): beobachtet Cursor/Selektion (debounced) und
  # verbindet sich ueber den Sidecar (WebSocket) mit pi's pi-x-ide-Erweiterung.
  # Live-Widget in pi: ⧉ flake.nix#L10-L18. Attach: Leertaste a a.
  # Das Sidecar-Binary laed das Plugin beim ersten Start selbst
  # (Node-Fallback vorhanden) — bewusst KEIN Build-Hook in Nix.
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      pname = "pi-x-ide";
      version = "unstable";
      src = pkgs.fetchFromGitHub {
        owner = "balaenis";
        repo = "pi-x-ide";
        rev = "e71423cbebb736702360d2eeb14e3432b5017e62";
        hash = "sha256-Tc9y6vgNVwGoDFwiQ++aRNK5I1iFs2CpGgbXywBS3MQ=";
      };
      sourceRoot = "source/ide-plugins/nvim";
    })
  ];

  extraConfigLua = ''
    require("pi_x_ide").setup({ keymap = "<leader>aa" })
  '';
}
