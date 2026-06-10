# PLUGINS — Adding and managing plugins

## 1. Three patterns, in priority order

### Pattern A: `plugins.<x>.enable = true`  (preferred)

Use when the plugin is in Nixvim's built-in plugin registry
(see https://nix-community.github.io/nixvim/plugins/).

```nix
{
  plugins = {
    dressing.enable = true;
    nui.enable       = true;
    lualine.enable   = true;
  };
}
```

That's it. `enable = true` adds the plugin to `extraPlugins`
(so it lands in packpath and is auto-sourced) and appends a
`require("<x>").setup({})` call to `extraConfigLua`. Configure
via `plugins.<x>.settings.<...>` — Nixvim translates the nix
attrset to a lua table.

### Pattern B: `extraPlugins` (plugin in nixpkgs, not in Nixvim)

Use when the plugin is in `pkgs.vimPlugins` but Nixvim has no
module for it. Configure via raw Lua in `extraConfigLua`.

```nix
{
  extraPlugins = with pkgs.vimPlugins; [ vim-toml ];
  extraConfigLua = ''
    require("vim-toml").setup({
      -- whatever the plugin's README shows
    })
  '';
}
```

### Pattern C: `mkNeovimPlugin` (plugin not in Nixvim's registry)

Use when you need a typed nix interface for a plugin (typed
`settingsOptions`, `dependencies`, etc.) but no module exists.
Copy the shape from any `plugins/by-name/<x>/default.nix` in
Nixvim's source into a local file:

```nix
# my-plugin.nix
{ lib, ... }:
lib.nixvim.plugins.mkNeovimPlugin {
  name        = "my-plugin";
  packPathName = "my-plugin.nvim";
  package     = "my-plugin";

  settingsOptions = {
    enabled = lib.nixvim.defaultNullOpts.mkBool true "";
    -- ...
  };
}
```

Then import it in your main config and enable normally:

```nix
{
  imports = [ ./my-plugin.nix ];
  plugins.my-plugin.enable = true;
}
```

### Pattern D (rare): plugin not in nixpkgs at all

Build it with `pkgs.vimUtils.buildVimPlugin` and pass to
`extraPlugins`:

```nix
{
  extraPlugins = [ (pkgs.vimUtils.buildVimPlugin {
    name = "my-plugin";
    src  = pkgs.fetchFromGitHub {
      owner = "..."; repo = "...";
      rev   = "..."; hash = "...";
    };
  }) ];
  extraConfigLua = ''require("my-plugin").setup({})'';
}
```

## 2. The lazy.nvim trap — do not do this

Lazy.nvim's `setup()` resets `vim.opt.packpath` to a single
entry (just the neovim runtime) and rebuilds `vim.opt.runtimepath`
to contain only the plugins explicitly listed in lazy's `spec`.
Every Nixvim-managed plugin (`enable = true`) not in the lazy
`spec` is dropped from the rtp.

This breaks plugins that lazy-`require` their own submodules
via patched `vim.ui.*` (e.g. dressing, snacks). Setup runs
fine (the plugin is in the rtp at that point), but the first
`vim.ui.input` call comes AFTER lazy.setup(), by which time
the plugin is gone. The result is `module 'dressing.input' not
found`.

**Rule: one plugin manager. Use Nixvim's native `enable`. If
you need lazy-loading, use `lz.n` (Nixvim's supported lazy
loader), not lazy.nvim.**

## 3. Plugin-specific config gotchas

| Plugin       | What to know                                            |
|--------------|---------------------------------------------------------|
| `lualine`    | Its `setup()` registers `ColorScheme` / `OptionSet` autocmds that fire during TUI startup. If you re-`setup()` lualine later (e.g. in `extraConfigLuaPost`), clear the original handlers first or you get a race where the theme config is lost. |
| `avante`     | Needs `NOUS_API_KEY` in env. If reading from a private secrets flake input, use `builtins.readFile` at evaluation time (not `builtins.fetchurl` at runtime) and inline it into `vim.env` via `extraConfigLua`. |
| `dressing`   | `require("dressing").setup({})` only loads the `dressing` init; `dressing.input` and `dressing.select` are lazy-required. This is fine with native `enable` (plugin stays in rtp) but breaks if you also use lazy.nvim. |
| `telescope`  | Extensions (`file_browser`, `fzf`, …) must be loaded explicitly via `require("telescope").load_extension("...")`. Configure extensions under `plugins.telescope.extensions.<name>.enable = true`. |
| `nvim-cmp`   | Source registration goes under `plugins.cmp.sources` (list of `{ name = "..."; ... }` entries). |
| `lazy.nvim`  | **Do not use.** See section 2. |

## 4. When to add a new plugin

Before adding, check:
1. Is it in Nixvim's registry? → Pattern A.
2. Is it in nixpkgs? → Pattern B.
3. Do you actually need it? (No dead code.)

Then check: is the desired feature already provided by a plugin
you have? Example: a fuzzy finder is already covered by
`telescope`; do not add `fzf.vim` on top.
