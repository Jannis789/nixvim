# AGENTS.md

A standalone Nixvim configuration. Built with `nix build .#default`,
run with `./result/bin/nvim` or `nix run`.

## Build & test

```
nix build .#default          # build the nvim package → ./result
./result/bin/nvim             # run it
nix flake check              # run the test derivation (sanity build)
nix flake update nixvim       # bump nixvim (rare; do not pin random commits)
```

Headless require smoke test (use after any plugin/enable change):

```
./result/bin/nvim --headless \
  -c 'lua local ok,err = pcall(require, "dressing.input");
      print(ok and "OK" or tostring(err))' -c 'q'
```

If a plugin is needed by `vim.ui.*` patches, the relevant check is
`vim.ui.input` actually firing (see `docs/NIXVIM.md` for the trap).

## Documentation

| File                  | Topic                                              |
|-----------------------|----------------------------------------------------|
| `docs/NIXVIM.md`      | Mental model: module system → init.lua, rtp, lazy |
| `docs/PLUGINS.md`     | How to add plugins (3 patterns + the lazy.nvim trap) |
| `docs/STYLE.md`       | Code style for the Nix config and embedded Lua    |
| `docs/KEYBINDS.md`    | Custom keybindings                                 |

External reference (read first when in doubt):
- https://nix-community.github.io/nixvim/  — generated option & plugin reference
- https://nix-community.github.io/nixvim/user-guide/install.html — 4 usage modes
- https://nix-community.github.io/nixvim/platforms/standalone.html — new evalNixvim API
- https://nix-community.github.io/nixvim/plugins/ — full plugin option list
