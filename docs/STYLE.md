# STYLE — Code style

## Nix

- **No dead code.** If a comment, option, or import is not
  serving a purpose, remove it. A commented-out "in case I need
  it later" is forbidden.
- **Comments explain WHY, not WHAT.** The code shows what; the
  comment should justify the choice or warn about a non-obvious
  consequence. Example: a comment above a `vim.api.nvim_clear_autocmds`
  call explaining which race condition it prevents.
- **Single point of truth.** If a value is used in two places
  (e.g. a colorscheme name in both Nixvim and a Lua fixup), put
  it in a `let`-binding at the top of the module and reference it
  twice. Never duplicate.
- **Prefer `lib.nixvim.*` over hand-rolled helpers.** Type
  construction (`mkSettingsOption`, `defaultNullOpts.mkBool`, …)
  is the same code Nixvim's own modules use; reusing it keeps
  your config in lockstep with the upstream option shapes.
- **Use the type system.** If Nixvim's option type rejects your
  value, that is correct behavior — fix the value, do not weaken
  the type with `lib.types.anything` to silence the error.
- **No mutation of imported attrsets.** Build a new attrset
  with overrides; do not `//` into `pkgs`.
- **Attribute names** describe the concept, not the value. Use
  `dressingSettings`, not `dressingCfg`. Use
  `extraSecretEnvFiles`, not `myFiles`.

## Lua (inside `extraConfigLua*`)

- **Use `vim.api` over `vim.cmd` where both work.** `vim.cmd` is
  string-parsed at runtime; `vim.api.*` is typed and faster.
- **`pcall(require, ...)` for any `require` that may not be on
  the rtp at the time of call.** Bare `require("foo")` is fine
  for plugins that `enable = true`; use pcall only when in doubt.
- **One `require` per line in setup blocks; do not chain.**
  ```lua
  -- bad
  local a, b = require("a"), require("b")

  -- good
  local a = require("a")
  local b = require("b")
  ```
- **Localize everything at module scope.** If a function
  captures `vim.g.foo` once and reuses it, capture into a
  local — do not re-read `vim.g.foo` on every call.
- **Error messages include the failing identifier.** `vim.notify(
  "lualine theme reload failed: " .. err, vim.log.levels.WARN )`
  not `vim.notify("error: " .. err)`.
- **No `print` in production code.** Use `vim.notify` with an
  appropriate level.

## Naming

- Variables and options: full descriptive names.
  `resumeVer` and `epoch` not `rv` and `e`.
- Booleans read as predicates: `autoLoad`, `lazyLoad`, `optional`
  — not `enabled`, `lazy`, `opt`.
- Functions/methods: verb or imperative. `reload_lualine`,
  `apply_extra_config`, not `lualine_reload`, `extra_config`.
- Tables/attrsets: noun. `DressingState`, `keymap_options`,
  not `dressing_data`, `opts_for_keymap`.

## Patches / workarounds

If you must add a patch (e.g. clearing autocmds before a
plugin's `setup` to fix a race), the comment above the patch
must:

1. Name the failure mode (what goes wrong without the patch).
2. Name the mechanism (which two things are racing, or which
   state assumption is violated).
3. Date the patch if it works around an upstream bug, so future
   you can check whether the upstream is fixed.

Style:

```nix
# Fix lualine ColorScheme/OptionSet autocommand race condition.
# lualine.setup() creates handlers that call setup() without
# arguments. When TermResponse fires during TUI startup
# (OptionSet background -> ColorScheme), the theme config is
# lost and the fallback chain fails. Clear and recreate fixed
# handlers that pass the theme explicitly.
vim.api.nvim_clear_autocmds({ group = "lualine", event = "ColorScheme" })
```

## Git

- One logical change per commit. "Fix dressing" + "bump lualine"
  in the same commit is not acceptable.
- Commit message subject: imperative, ≤ 72 chars.
  `dressing: use lz.n instead of lazy.nvim spec`
  not `fixed dressing thing`.
- Body explains *why*, not *what*. Diff shows the what.
