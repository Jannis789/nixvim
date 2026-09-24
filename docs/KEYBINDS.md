# KEYBINDS — Custom keybindings

## Buffer navigation

| Key | Action              | Beschreibung             |
|-----|---------------------|--------------------------|
| `n` | `BufferLineCyclePrev` | Zum vorherigen Tab (links) |
| `m` | `BufferLineCycleNext` | Zum nächsten Tab (rechts)  |

## pi (headless über pi.nvim)

| Keybinding | Beschreibung |
|------------|--------------|
| `<leader>d` / `3` | Pi-Ask: Prompt eingeben, aktueller Buffer ist Kontext; pi editiert Dateien, Buffer werden neu geladen |
| `<leader>d` / `3` (visual) | PiAskSelection: Selektion als zusätzlichen Kontext |
| `<leader>D` | Laufende pi-Anfrage abbrechen |
| `:PiLog` | Session-Log in neuem Split öffnen |
| `ctrl+x` (im pi-Terminal) | Laufende Generierung abbrechen (`esc` gehört nvim) |

## Fenstergröße

| Keybinding | Beschreibung |
|------------|--------------|
| `<C-w>a` | Split breiter (halten für Key-Repeat) |
| `<C-w>d` | Split schmaler |
| `<C-w>A` | Split höher |
| `<C-w>D` | Split flacher |

## Telescope

| Keybinding   | Beschreibung             |
|--------------|--------------------------|
| `<leader>ff` | Find Files               |
| `<leader>fg` | Live Grep                |
| `<leader>fb` | Buffers                  |
| `<leader>fh` | Help Tags                |

Datei wird in AGENTS.md referenziert.
