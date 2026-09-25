# KEYBINDS — Custom keybindings

## Scopes (1/2/3, nur Normal-Mode)

| Taste | Wirkung |
|-------|---------|
| `1` | Tree: zu wenn fokussiert, sonst öffnen+fokussieren |
| `2` | Editor: erstes Editor-Fenster fokussieren |
| `3` / `Tab` | pi: öffnen/fokussieren/verstecken (Session bleibt leben) — auch im Visual-Mode |

## Buffer navigation

| Key | Action              | Beschreibung             |
|-----|---------------------|--------------------------|
| `n` | `BufferLineCyclePrev` | Zum vorherigen Tab (links) |
| `m` | `BufferLineCycleNext` | Zum nächsten Tab (rechts)  |

## pi (TUI-Split — Taste `3` oder `Tab`, Normal- und Visual-Mode)

| Taste | Wirkung |
|-------|---------|
| `3` / `Tab` | pi öffnen / fokussieren / verstecken (Session bleibt beim Verstecken leben) |
| IDE-Kontext | pi-ide-context: Datei, Cursor und Selektion fließen automatisch in jede pi-Nachricht (Selektion 60 s frisch, sichtbar als Zitatzeile in der gesendeten Nachricht) |
| Verbindung | Automatisch: pi verbindet sich beim ersten Öffnen selbst mit diesem nvim-Fenster (bei mehreren Editoren `/ide` manuell, `/ide off` trennt) |
| Fensterwechsel | Visual-Selektion bleibt erhalten und wird beim Zurückkehren ins Fenster wieder aktiv |
| `Esc` | Im pi-Split in den Normal-Mode des Splits |
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
