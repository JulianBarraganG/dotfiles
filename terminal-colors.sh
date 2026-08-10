#!/usr/bin/env bash
# Apply the tokyonight-moon palette to this machine's terminal emulator.
#
# Terminal colors are NOT a dotfile — each emulator keeps them in its own store,
# so they can't be synced by copying files like nvim/tmux configs are. This
# script bridges that gap: one palette (colors/tokyonight_moon.json) is applied
# to whichever terminal it finds.
#
#   GNOME Terminal (Ubuntu)      -> dconf, via gsettings
#   Windows Terminal (WSL)       -> settings.json on the Windows filesystem
#
# Run once per machine, after sync.sh. Idempotent — safe to re-run.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEME="$REPO/colors/tokyonight_moon.json"

[ -f "$SCHEME" ] || { echo "Palette not found: $SCHEME" >&2; exit 1; }

# Windows Terminal's palette slots, in the order GNOME Terminal's `palette` key
# expects them (0-7 normal, 8-15 bright). Both terminals get the same 16 colors
# in the same slots — that is the whole point of this script.
SLOTS=(black red green yellow blue purple cyan white
       brightBlack brightRed brightGreen brightYellow
       brightBlue brightPurple brightCyan brightWhite)

need_jq() {
    command -v jq >/dev/null 2>&1 || {
        echo "jq is required to edit terminal configs. Install it: sudo apt install jq" >&2
        exit 1
    }
}

# ---------------------------------------------------------------- GNOME Terminal

apply_gnome() {
    local prof base palette key backup
    # `|| true` is load-bearing: gsettings exits 1 when the schema is absent, and
    # `set -eo pipefail` would kill the script here before the guard below runs.
    prof=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'") || true
    [ -n "$prof" ] || return 1

    base="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$prof/"

    # Unlike Windows Terminal's single JSON file, dconf has no file to copy — so
    # dump the current profile tree before touching anything. Restore with:
    #   dconf load /org/gnome/terminal/legacy/profiles:/ < <backup>
    backup="$HOME/.local/state/dotfiles-gnome-terminal-backup.dconf"
    if command -v dconf >/dev/null 2>&1 && [ ! -f "$backup" ]; then
        mkdir -p "$(dirname "$backup")"
        dconf dump /org/gnome/terminal/legacy/profiles:/ > "$backup" 2>/dev/null || rm -f "$backup"
    fi

    # Build a GVariant string array: ['#1b1d2b', '#ff757f', ...]
    palette="["
    for key in "${SLOTS[@]}"; do
        palette+="'$(jq -r --arg k "$key" '.[$k]' "$SCHEME")', "
    done
    palette="${palette%, }]"

    gsettings set "$base" use-theme-colors false
    gsettings set "$base" background-color "$(jq -r .background "$SCHEME")"
    gsettings set "$base" foreground-color "$(jq -r .foreground "$SCHEME")"
    gsettings set "$base" palette "$palette"
    gsettings set "$base" cursor-colors-set true
    gsettings set "$base" cursor-background-color "$(jq -r .cursorColor "$SCHEME")"
    gsettings set "$base" cursor-foreground-color "$(jq -r .background "$SCHEME")"
    gsettings set "$base" bold-color-same-as-fg true

    echo "GNOME Terminal: applied '$(jq -r .name "$SCHEME")' to profile $prof"
    [ -f "$backup" ] && echo "  previous settings backed up to $backup"
    echo "Open a new terminal window to see it."
}

# ------------------------------------------------------------- Windows Terminal

# Echo the path to Windows Terminal's settings.json, or nothing if not found.
find_wt_settings() {
    [ -n "${WT_SETTINGS:-}" ] && { [ -f "$WT_SETTINGS" ] && echo "$WT_SETTINGS"; return; }
    local p
    for p in /mnt/c/Users/*/AppData/Local/Packages/Microsoft.WindowsTerminal_*/LocalState/settings.json \
             /mnt/c/Users/*/AppData/Local/Packages/Microsoft.WindowsTerminalPreview_*/LocalState/settings.json \
             "/mnt/c/Users/"*"/AppData/Local/Microsoft/Windows Terminal/settings.json"; do
        [ -f "$p" ] && { echo "$p"; return; }
    done
}

apply_windows_terminal() {
    local wt tmp
    wt=$(find_wt_settings)
    [ -n "$wt" ] || return 1
    need_jq

    # Windows Terminal permits // comments; jq does not. Strip only whole-line
    # comments (never mid-line, which would corrupt paths like C:\\foo//bar).
    if ! jq -e . "$wt" >/dev/null 2>&1; then
        if ! sed 's|^[[:space:]]*//.*$||' "$wt" | jq -e . >/dev/null 2>&1; then
            echo "Could not parse $wt as JSON (block comments?). Edit it by hand." >&2
            return 1
        fi
    fi

    # Keep one pristine copy of whatever was there before this script first ran.
    [ -f "$wt.dotfiles-bak" ] || cp "$wt" "$wt.dotfiles-bak"

    tmp=$(mktemp)
    # A colorScheme set ON a profile beats profiles.defaults, so the per-profile
    # keys are deleted rather than left to silently win. defaults becomes the one
    # lever, and profiles added later inherit it for free.
    sed 's|^[[:space:]]*//.*$||' "$wt" | jq --slurpfile s "$SCHEME" '
        ($s[0]) as $scheme
        | .schemes = ((.schemes // []) | map(select(.name != $scheme.name)) + [$scheme])
        | .profiles.defaults.colorScheme = $scheme.name
        | if (.profiles.list? | type) == "array"
          then .profiles.list |= map(del(.colorScheme))
          else . end
    ' > "$tmp"

    # Overwrite in place rather than mv: preserves the Windows ACLs on the file,
    # which a rename across DrvFs would drop.
    cat "$tmp" > "$wt"
    rm -f "$tmp"

    echo "Windows Terminal: applied '$(jq -r .name "$SCHEME")' to all profiles"
    echo "  $wt"
    echo "  (backup: $(basename "$wt").dotfiles-bak)"
    echo "Windows Terminal picks this up on save — reopen a tab if it doesn't."
}

# ----------------------------------------------------------------------- dispatch

applied=0

if command -v gsettings >/dev/null 2>&1; then
    apply_gnome && applied=1 || true
fi

if apply_windows_terminal; then
    applied=1
fi

if [ "$applied" -eq 0 ]; then
    echo "No supported terminal found (looked for GNOME Terminal and Windows Terminal)."
    echo "Colors unchanged. Add a branch to $(basename "$0") for this machine's terminal."
fi
