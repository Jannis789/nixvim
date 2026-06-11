{ lib, secrets, ... }:

let
  inherit (builtins) readFile match;

  # secrets/nvim-env contains: export NOUS_API_KEY=<token>
  envFile = readFile (toString secrets + "/nvim-env");
  # Extract the value after NOUS_API_KEY=
  apiKey = let
    m = match ".*NOUS_API_KEY=([^\n]*).*" envFile;
  in if m != null then builtins.head m else
    builtins.abort "avante.nix: NOUS_API_KEY not found in secrets/nvim-env. Add 'export NOUS_API_KEY=xxx' to the file.";
in
{
  plugins.avante = {
    enable = true;

    settings = {
      provider = "nous";

      auto_suggestions_provider = "nous";

      providers = {
        nous = {
          __inherited_from = "openai";
          endpoint = "https://inference-api.nousresearch.com/v1";
          model = "deepseek/deepseek-v4-flash";
          api_key_name = "NOUS_API_KEY";
          timeout = 30000;
          allow_insecure = false;
          extra_request_body = {
            temperature = 0;
            max_tokens = 4096;
          };
        };
      };

      mappings = {
        diff = {
          ours = "co";
          theirs = "ct";
          none = "c0";
          both = "cb";
          next = "]x";
          prev = "[x";
        };
        jump = {
          next = "]]";
          prev = "[[";
        };
      };

      hints.enabled = true;

      windows = {
        wrap = true;
        width = 45;
        sidebar_header = {
          align = "center";
          rounded = true;
        };
      };

      highlights.diff = {
        current = "DiffText";
        incoming = "DiffAdd";
      };

      diff = {
        debug = false;
        autojump = true;
        list_opener = "copen";
      };
    };
  };

  # Inject the API key into vim.env at build time.
  # Using Lua long brackets [[ ]] to avoid escaping issues.
  # Must be extraConfigLuaPre so it runs BEFORE avante.setup().
  extraConfigLuaPre = ''
    vim.env.NOUS_API_KEY = [[${apiKey}]]
  '';
}
