#!/usr/bin/env bash
# Apply the tokyonight-moon background/foreground to the default GNOME Terminal
# (VTE) profile. This is a dconf/gsettings setting, not a dotfile, so it must be
# run once per machine. Idempotent — safe to re-run.
set -euo pipefail

BG="#222436"   # tokyonight-moon background
FG="#c8d3f5"   # tokyonight-moon foreground

if ! command -v gsettings >/dev/null 2>&1; then
    echo "gsettings not found (not a GNOME/VTE terminal). Skipping."
    exit 0
fi

prof=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'")
if [ -z "$prof" ]; then
    echo "No default GNOME Terminal profile found. Skipping."
    exit 0
fi

base="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$prof/"
gsettings set "$base" use-theme-colors false
gsettings set "$base" background-color "$BG"
gsettings set "$base" foreground-color "$FG"

echo "Applied bg=$BG fg=$FG to GNOME Terminal profile $prof"
echo "Open a new terminal window to see it."
