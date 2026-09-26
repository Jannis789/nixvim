#!/usr/bin/env bash
# pi-Setup: pi-seitige Integration idempotent reinstallieren.
# Wann: nach pi-Update, auf neuem Rechner, oder wenn IDE-Widget/Kontext hakt.
# Pinning: PIN_REV muss zur rev in config/ai/pi-x-ide.nix passen (wird geprueft).
set -euo pipefail

PIN_REV="e71423c"
PI_AGENT="${PI_AGENT:-$HOME/.pi/agent}"
G="$PI_AGENT/git/github.com/balaenis/pi-x-ide"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

g()  { printf '\033[1;36m==\033[0m %s\n' "$*"; }
ok() { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
no() { printf '\033[1;33m  !\033[0m %s\n' "$*"; }

# 0) Rev-Konsistenz mit der nvim-Seite
NIX_REV="$(sed -nE 's/.*rev = "([0-9a-f]+)".*/\1/p' "$REPO/config/ai/pi-x-ide.nix" | head -1)"
if [ -z "$NIX_REV" ]; then
  no "keine rev in config/ai/pi-x-ide.nix gefunden — Struktur geaendert?"
elif [ "${NIX_REV:0:7}" != "${PIN_REV:0:7}" ]; then
  no "Rev-Drift: pi-x-ide.nix=${NIX_REV:0:7}, Script=$PIN_REV — zuerst das Pinning angleichen."
  exit 1
else
  ok "Rev-Konsistenz: ${NIX_REV:0:7}"
fi

# 1) pg fuer mem0ai (OSS-Modul importiert alle Vektorstore-Provider statisch)
g "pg (mem0ai)"
if node -e "require.resolve('pg', { paths: ['$PI_AGENT/npm/node_modules/mem0ai'] })" 2>/dev/null; then
  ok "vorhanden"
else
  (cd "$PI_AGENT/npm" && npm install pg@8.11.3 --no-audit --no-fund >/dev/null 2>&1)
  ok "pg@8.11.3 installiert"
fi

# 2) pi-x-ide-Checkout auf die gepinnte Rev (pi install kann nicht nach SHA fetchen)
g "pi-x-ide-Checkout ($PIN_REV)"
if [ -d "$G/.git" ]; then
  git -C "$G" fetch origin >/dev/null 2>&1 || no "fetch fehlgeschlagen (offline?) — lokaler Stand wird genutzt"
else
  mkdir -p "$(dirname "$G")"
  git clone --quiet https://github.com/balaenis/pi-x-ide "$G"
fi
git -C "$G" checkout --force --quiet "$PIN_REV"
ok "auf ${PIN_REV} ($(git -C "$G" log -1 --format=%h))"

# 3) dist bauen (nur wenn fehlt oder aelter als src)
g "pi-x-ide dist"
if [ -f "$G/dist/src/pi/index.js" ] && [ "$G/dist/src/pi/index.js" -nt "$G/src" ]; then
  ok "aktuell"
else
  (cd "$G" && (npm ci --workspaces=false >/dev/null 2>&1 || npm install --workspaces=false >/dev/null 2>&1))
  (cd "$G" && node scripts/build-pi-entry.mjs >/dev/null 2>&1)
  test -f "$G/dist/src/pi/index.js"
  ok "gebaut"
fi

# 4) pi-x-ide-Basispaket im pi-npm-Tree
g "pi-x-ide (npm-Tree)"
if [ -d "$PI_AGENT/npm/node_modules/pi-x-ide" ]; then
  ok "vorhanden ($(grep -o '"version": *"[^"]*"' "$PI_AGENT/npm/node_modules/pi-x-ide/package.json" | head -1 | grep -oE '[0-9][^"]*'))"
else
  pi install npm:pi-x-ide >/dev/null 2>&1 && ok "installiert" || no "pi install fehlgeschlagen"
fi

# 5) Extensions deployen (Cursor-Status-Anzeige in pi)
g "pi-Extensions"
for f in "$REPO"/scripts/pi/extensions/*.ts; do
  [ -e "$f" ] || { no "keine Extensions im Repo (scripts/pi/extensions/)"; break; }
  b="$(basename "$f")"
  if cmp -s "$f" "$PI_AGENT/extensions/$b"; then
    ok "$b identisch"
  else
    cp "$f" "$PI_AGENT/extensions/$b"
    ok "$b deployt"
  fi
done

# 6) nvim-Smoke-Test
g "nvim-Smoke-Test"
if [ -x "$REPO/result/bin/nvim" ]; then
  if "$REPO/result/bin/nvim" --headless -c 'lua assert(vim.fn.exists(":PiSel") == 2, "PiSel fehlt") print("SMOKE_OK")' -c 'qa!' 2>&1 | grep -q SMOKE_OK; then
    ok "nvim laedt die Integration (:PiSel vorhanden)"
  else
    no "nvim ohne :PiSel — nach Konfig-Aenderungen 'nix build .#default' ausfuehren"
  fi
else
  no "./result/bin/nvim fehlt — 'nix build .#default' fuer den Smoke-Test"
fi

printf '\n\033[1;32mpi-Setup fertig.\033[0m\n'
