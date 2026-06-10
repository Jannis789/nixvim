{ pkgs, secrets, ... }:

let
  # Read API key from private secrets flake input at build time.
  # The key is baked into the Nix store (only readable by your user).
  # The public Git repo only contains the flake input URL, not the key value.
  envFile = builtins.readFile "${secrets}/nvim-env";
  match = builtins.match ".*NOUS_API_KEY=([^[:space:]]+).*" envFile;
  nousKey = if match != null then builtins.elemAt match 0 else "";
in
{
  colorschemes.catppuccin = {
    enable = true;
    settings = {
      contrastDark = true;
      transparentBg = true;
    };
  };

  # ============================================================
  # AI: minuet-ai.nvim – Inline autocompletion via Nous API
  # ============================================================
  extraPlugins = [
    pkgs.vimPlugins.minuet-ai-nvim
  ];

  extraConfigLua = ''
    -- API key baked in at build time from private secrets submodule
    vim.env.NOUS_API_KEY = "${nousKey}"

    require('minuet').setup({
      provider = 'openai_compatible',
      provider_options = {
        openai_compatible = {
          api_key = '${nousKey}',
          end_point = 'https://inference-api.nousresearch.com/v1/chat/completions',
          model = 'NousResearch/Hermes-3-Llama-3.1-8B',
          name = 'Nous',
          optional = {
            max_tokens = 256,
            stop = { '\n', '\r' },
          },
        },
      },
      throttle = 1000,   -- ms between API calls
      debounce = 150,    -- ms debounce before triggering
    })
  '';

  plugins = {
    # ============================================================
    # AI: Avante (Cursor-like IDE experience) via Nous
    # ============================================================
    avante = {
      enable = true;
      autoLoad = true;
      settings = {
        provider = "nous";
        auto_suggestions_provider = "nous";
        hints.enabled = true;
        diff.autojump = true;
        windows = {
          width = 30;
          wrap = true;
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
        };
        providers = {
          nous = {
            __inherited_from = "openai";
            endpoint = "https://inference-api.nousresearch.com/v1";
            api_key_name = "NOUS_API_KEY";
            model = "NousResearch/Hermes-3-Llama-3.1-8B";
          };
        };
      };
    };

    # ============================================================
    # Treesitter: Syntax highlighting & code understanding
    # ============================================================
    treesitter = {
      enable = true;
      settings = {
        highlight = { enable = true; };
        indent = { enable = true; };
        folding = { enable = true; };
      };
    };

    # --- Avante runtime dependencies ---
    dressing.enable = true;
    nui.enable = true;
    web-devicons.enable = true;  # Explicit; used by telescope & avante

    # ============================================================
    # Telescope: Fuzzy finder
    # ============================================================
    telescope = {
      enable = true;
      keymaps = {
        "<leader>ff" = {
          action = "find_files";
          options.desc = "Find Files";
        };
        "<leader>fg" = {
          action = "live_grep";
          options.desc = "Live Grep";
        };
        "<leader>fb" = {
          action = "buffers";
          options.desc = "Buffers";
        };
        "<leader>fh" = {
          action = "help_tags";
          options.desc = "Help Tags";
        };
      };
      extensions = {
        file-browser = {
          enable = true;
        };
      };
    };

    # ============================================================
    # nvim-cmp: Completion engine
    # ============================================================
    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = "cmp.mapping.select_next_item()";
          "<S-Tab>" = "cmp.mapping.select_prev_item()";
        };
        sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
          { name = "luasnip"; }
        ];
      };
    };

    # ============================================================
    # Lualine: Status line
    # ============================================================
    lualine = {
      enable = true;
      settings = {
        options = {
          theme = "catppuccin";
        };
      };
    };

    # ============================================================
    # Lazy-loaded plugins (no native nixvim module available)
    # ============================================================
    lazy = {
      enable = true;

      plugins = [
        # --- Git integration ---
        {
          name = "vim-fugitive";
          pkg = pkgs.vimPlugins.vim-fugitive;
          event = [ "VimEnter" ];
        }
      ];
    };
  };
}
