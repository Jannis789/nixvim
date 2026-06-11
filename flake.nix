{
  description = "A Nixvim configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixvim.url = "github:nix-community/nixvim";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Private secrets (API keys, tokens). Passed to config modules
    # via extraSpecialArgs. Set secrets.flake = false.
    # Uncomment and add a files/nvim-env entry when avante etc. are configured:
    secrets.url = "git+ssh://git@github.com/Jannis789/secrets.git?ref=main";
    secrets.flake = false;
  };

  outputs =
    { nixvim, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { system, ... }:
        let
          configuration = nixvim.lib.evalNixvim {
            inherit system;

            modules = [ ./config ];

            # Pass non-flake inputs (like secrets) to config modules.
            # Secrets are accessed as `{ secrets, ... }:` in any module.
            extraSpecialArgs = { inherit (inputs) secrets; };
          };
        in
        {
          checks.default = configuration.config.build.test;
          packages.default = configuration.config.build.package;
        };
    };
}
