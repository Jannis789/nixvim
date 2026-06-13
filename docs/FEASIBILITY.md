# Machbarkeitsanalyse — Neues Keybinding-Konzept (v3)

Stand: 13.06.2026
Basis: aktuelle nixvim-Repo-Struktur + Hermes ACP Docs + agentic.nvim

---

## 1. Aktuelle Bestandsaufnahme

| Plugin | Status | Keybinding |
|---|---|---|
| nvim-tree (Treeview) | aktiv | `<Tab>` = Toggle, `<leader>e` = Toggle |
| bufferline (Tabs) | aktiv | `n` = CyclePrev, `m` = CycleNext |
| telescope (Suche) | aktiv | `<leader>ff` = Files, `<leader>fg` = Grep |
| avante (AI-Chat) | aktiv | `<leader>d` = AvanteChat |
| Terminal | **nicht vorhanden** | — |
| Leader-Key | `Space` | `globals.mapleader = " "` |

---

## 2. Scope-System: "In jedem Scope aktiv (bis auf insert)"

Nixvim `keymaps` unterstützt `mode` als Liste:

```nix
keymaps = [{
  key = "<Space>p>";
  action = "<cmd>Telescope find_files<CR>";
  options.desc = "Find Files";
  mode = ["n" "v" "x" "s" "o" "t" "l" "c"];
}]
```

Modes: `n`=normal, `v`=visual+select, `x`=visual, `s`=select, `o`=operator-pending,
`t`=terminal, `l`=langmap, `c`=command-line.

✅ **Nativ in nixvim umsetzbar.**

---

## 3. Keybinding-Einzelanalyse

### 3.1 n/m: Tab-Navigation (Scope-übergreifend)

**Gewünscht:** `n` = CyclePrev, `m` = CyclePrev — in ALLEN Scopes außer insert.
**User-Feedback:** "klappt ja im editor schon, nur nicht global"

**Problem:**
Bufferline definiert n/m als globale Keymaps. Diese funktionieren in normalen
Editor-Buffern, werden aber von **nvim-tree** und **Avante-Chat-Buffern** durch
buffer-lokale Mappings überschrieben.

**Lösung:**

1. **nvim-tree on_attach** — buffer-lokale n/m explizit löschen (falls vorhanden):
   ```lua
   vim.keymap.del("n", "n", { buffer = bufnr })
   vim.keymap.del("n", "m", { buffer = bufnr })
   ```

2. **Avante/Agentic Chat-Buffer** — n/m per FileType-Autocmd setzen:
   ```lua
   vim.api.nvim_create_autocmd("FileType", {
     pattern = "Avante*",
     callback = function()
       vim.keymap.set("n", "n", ":BufferLineCyclePrev<CR>", { buffer = true, silent = true })
       vim.keymap.set("n", "m", ":BufferLineCyclePrev<CR>", { buffer = true, silent = true })
     end,
   })
   ```

3. **Alle Modi außer insert:**
   ```nix
   mode = ["n" "v" "x" "s" "o" "t" "l" "c"];
   ```

✅ **Machbar.**

---

### 3.2 Tab → Terminal

**Problem:** `<Tab>` ist aktuell an `NvimTreeToggle` gebunden. Der on_attach löscht
extra die Tab-Preview-Map im Tree-Buffer, damit Tab global frei ist.

**Lösung:**
- Tree-Toggle von `<Tab>` entfernen, nur `<leader>e` behalten
- toggleterm installieren, `<Tab>` als Terminal-Toggle mappen

```nix
# config/terminal.nix
{ ... }: {
  plugins.toggleterm = {
    enable = true;
    settings = {
      size = 20;
      open_mapping = "<Tab>";
      direction = "horizontal";
    };
  };
}
```

✅ **Machbar.**

---

### 3.3 Space+p / Space+o

**Space+p → `Telescope find_files`**, **Space+o → `Telescope live_grep`**

Aktuell: `<leader>ff` / `<leader>fg`. Keine Konflikte.

✅ **Direkt umsetzbar.**

---

### 3.4 Ctrl+s (Chat-Senden)

User-Feedback: "chat abschicken ist bereits der default"

❌ **Nicht nötig — Avante/Agentic haben bereits Default-Submit.**

---

## 4. AI-CHAT: ACP-Integration — DER DURCHBRUCH

### Was wir gelernt haben

1. **Hermes ACP** (`hermes acp`) ist ein ACP-Server über stdio — designed für
   VS Code (ACP Client Extension), Zed, JetBrains.

2. **Agentic.nvim** (`carlos-algms/agentic.nvim`, 511 ★) ist ein Neovim-Plugin
   das **nativ das Agent Client Protocol (ACP) implementiert**. Es funktioniert
   mit JEDEM ACP-kompatiblen Provider.

3. **Agentic.nvim erlaubt Custom ACP Provider:**
   ```lua
   acp_providers = {
     ["hermes-acp"] = {
       name = "Hermes Agent",
       command = "hermes",
       args = { "acp" },
       env = {
         HERMES_HOME = os.getenv("HERMES_HOME"),
       },
     },
   }
   ```

### Resultierende Architektur

```
agentic.nvim (Neovim) ←→ ACP stdio ←→ hermes acp (Hermes Agent)
```

- Agentic.nvim startet `hermes acp` als Subprozess
- Kommunikation via JSON-RPC über stdin/stdout
- Hermes' volle Tool-Palette (file, terminal, web, skills, delegation, ...)
- Kein Proxy, keine Bridge, keine zusätzliche Infrastruktur

### Agentic.nvim vs. Avante — Feature-Vergleich

| Feature | Avante.nvim | agentic.nvim |
|---|---|---|
| ACP-nativ | ❌ (nur HTTP) | ✅ |
| Chat-Sidebar | ✅ | ✅ |
| Diff-Ansicht | ✅ | ✅ |
| Modell-Wechsel | ❌ (per Config) | ✅ (mid-session) |
| Provider-Wechsel | ❌ | ✅ (mid-session) |
| Session-Restore | ❌ | ✅ (terminal ↔ nvim) |
| Dateien-Kontext | ✅ | ✅ |
| Image-Support | ✅ | ✅ |
| Slash-Commands | ❌ | ✅ (native Vim-Completion) |
| Multi-Agent (pro Tab) | ❌ | ✅ |
| MCP-Server | ✅ (via Config) | ✅ (vom ACP-Provider geerbt) |
| Hermes-Integration | Proxy nötig | ✅ nativ |

### Nixvim-Konfiguration für agentic.nvim

Da agentic.nvim (noch) kein nixvim-Plugin ist, wird es via `extraPlugins` +
`extraConfigLua` eingebunden:

```nix
{ ... }: {
  plugins.avante.enable = false;  # ersetzen

  extraPlugins = with pkgs.vimPlugins; [{
    plugin = agentic-nvim;  # falls in nixpkgs vorhanden
  }];

  # Falls nicht in nixpkgs: via fetchFromGitHub oder pluginWithConfig
  extraPlugins = [{
    plugin = pkgs.vimUtils.buildVimPlugin {
      name = "agentic-nvim";
      src = pkgs.fetchFromGitHub {
        owner = "carlos-algms";
        repo = "agentic.nvim";
        rev = "main";  # oder aktuelles Release
        hash = "...";
      };
    };
  }];

  extraConfigLua = ''
    require("agentic").setup({
      provider = "hermes-acp",
      acp_providers = {
        ["hermes-acp"] = {
          name = "Hermes Agent",
          command = "hermes",
          args = { "acp" },
        },
      },
      windows = {
        position = "right",
        width = "40%",
      },
    })
  '';

  keymaps = [
    {
      key = "<leader>d";
      action.__raw = ''function() require("agentic").toggle() end'';
      options.desc = "Toggle Agentic Chat";
      mode = ["n" "v"];
    }
  ];
}
```

---

## 5. Zusammenfassung

| Binding | Status | Aufwand |
|---|---|---|
| `n` / `m` global | ✅ Machbar | Gering (on_attach + Autocmd) |
| `<Tab>` → Terminal | ✅ Machbar | Gering (toggleterm + Tree-Umstellung) |
| `<Space>p` → Files | ✅ Machbar | Gering (Telescope-Mapping) |
| `<Space>o` → Grep | ✅ Machbar | Gering (Telescope-Mapping) |
| **ACP-Integration** | **✅ agentic.nvim** | **Mittel (Plugin-Einbindung + Konfiguration)** |

### Empfohlenes finales Layout

| Key | Scope | Action | Plugin |
|---|---|---|---|
| `n` / `m` | Alle außer insert | Tab left/left | bufferline |
| `<Space>p` | Alle außer insert | Dateisuche | telescope |
| `<Space>o` | Alle außer insert | Codesuche | telescope |
| `<Tab>` | Alle außer insert | Terminal toggle | toggleterm |
| `<leader>e` | — | Tree toggle | nvim-tree |
| `<leader>d` | — | Chat toggle | agentic.nvim |
| `<C-s>` | — | (Default, nichts tun) | agentic.nvim |

### Empfohlene Änderungen am Repo

1. **`config/terminal.nix`** (neu) — toggleterm
2. **`config/tree.nix`** — `<Tab>` raus, nur `<leader>e`
3. **`config/bufferline.nix`** — mode auf alle außer insert
4. **`config/telescope.nix`** — `<leader>ff` → `<leader>p`, `<leader>fg` → `<leader>o`
5. **`config/avante.nix`** → **`config/agentic.nix`** (neu, ersetzt avante)

---

## 6. Offene Punkte

1. Ist agentic.nvim in nixpkgs (`pkgs.vimPlugins.agentic-nvim`) oder via fetchFromGitHub?
2. Hermes muss auf dem System-PATH sein (`hermes acp` muss agentic.nvim erreichbar sein)
3. agentic.nvim braucht Neovim ≥ 0.11.0

Soll ich Phase 1 (alle Keybindings) direkt umsetzen?
