# KEYBINDS — Custom keybindings

## Scopes (1/2/3, nur Normal-Mode)

| Taste | Wirkung |
|-------|---------|
| `1` | Tree: zu wenn fokussiert, sonst öffnen+fokussieren |
| `2` | Editor: erstes Editor-Fenster fokussieren |
| `3` / `Tab` | pi: öffnen/fokussieren/verstecken (Session bleibt leben) — im Visual-Mode; aus dem Chat heraus mit `Esc` (→ Editor) und dann `3` |

## Buffer navigation

| Key | Action              | Beschreibung             |
|-----|---------------------|--------------------------|
| `n` | `BufferLineCyclePrev` | Zum vorherigen Tab (links) |
| `m` | `BufferLineCycleNext` | Zum nächsten Tab (rechts)  |
| `Leertaste b d` | smart-close | Schließt den Tab und wechselt automatisch auf einen anderen; der letzte Buffer bleibt offen; ungespeicherte Änderungen: erst `:w` |

## pi (TUI-Split — Taste `3` oder `Tab`, Normal- und Visual-Mode)

| Taste | Wirkung |
|-------|---------|
| `3` / `Tab` | pi öffnen / fokussieren / verstecken (Session bleibt beim Verstecken leben) |
| IDE-Kontext | pi-ide-context: Datei, Cursor und Selektion fließen automatisch in jede pi-Nachricht (Selektion 60 s frisch, sichtbar als Zitatzeile in der gesendeten Nachricht) |
| IDE-Kontext | pi-x-ide: Live-Widget in pi (`⧉ flake.nix#L10-L18`); `Leertaste a a` hängt die Selektion als `@datei#Lx-Ly` an die Eingabe |
| `/ide status` (in pi) | pi-x-ide Verbindungs-Status; `/ide off` trennt |
| Fensterwechsel | Die Markierung bleibt im Editor-Fenster sichtbar (eingefroren), bis eine neue Selektion sie ersetzt |
| `Esc` | Zurück in den Editor (pi bleibt offen). Terminal-Normal nur manuell via `Strg+\ Strg+N` (z. B. zum Kopieren) |
| `ctrl+x` (im pi-Terminal) | Laufende Generierung abbrechen (`esc` gehört nvim) |

## Git (gitsigns)

| Keybinding | Beschreibung |
|------------|--------------|
| (Gutter) | `+` neu, `~` geändert, `_` entfernt |
| `<leader>hp` | Hunk-Vorschau (diff des Blocks unter dem Cursor) |
| `<leader>hd` | Datei-Diff gegen den Index in neuem Split |

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
| `Space p` | Dateien suchen (Find Files) |
| `Space o` | Text im Projekt suchen (Live Grep) |
| `Space fb` | Buffer wechseln |
| `Space fh` | Help Tags |

Datei wird in AGENTS.md referenziert.
