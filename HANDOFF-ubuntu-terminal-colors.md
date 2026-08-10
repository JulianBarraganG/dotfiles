# Handoff: verify `terminal-colors.sh` on the Ubuntu machine

Paste the section below to Claude Code on the Ubuntu machine, from `~/dotfiles`.
Delete this file once the GNOME path is confirmed working.

---

I'm on my Ubuntu machine. In a previous session on my Windows/WSL machine, we
reworked `~/dotfiles/terminal-colors.sh` so one script applies the same
tokyonight-moon palette to whatever terminal a machine uses. I need you to
verify the GNOME Terminal path, because it was written **without ever being
executed** — that machine has no GNOME Terminal, so the entire `apply_gnome`
function is unverified guesswork about key names and value formats.

What was done:

- `colors/tokyonight_moon.json` is the single source of truth for the palette
  (16 ANSI colors + bg/fg/cursor/selection), vendored into the repo so it does
  not depend on the tokyonight nvim plugin being installed yet.
- `terminal-colors.sh` detects the terminal and dispatches: GNOME Terminal via
  `gsettings`, Windows Terminal via its `settings.json` under `/mnt/c`.
- The **Windows Terminal path was fully verified** — tested on a copy, confirmed
  idempotent, confirmed `profiles.list` otherwise untouched, then applied for
  real. Don't change it without reason.
- The **GNOME path was never run.** Treat it as a draft.

Specifically, please check on this machine:

1. Does it work at all? Run `./terminal-colors.sh` and see whether the profile
   actually picks up the theme in a new terminal window.
2. Do the key names in `apply_gnome` exist in this GNOME version? Compare
   against `gsettings list-keys` for the profile — particularly
   `bold-color-same-as-fg`, `cursor-colors-set`, `cursor-background-color`,
   `cursor-foreground-color`.
3. Is the `palette` value format right? The script passes a GVariant array of
   hex strings, `['#1b1d2b', '#ff757f', ...]`. Upstream tokyonight's own dconf
   extra uses `'rgb(27, 29, 43)'` form instead. If hex is rejected or renders
   wrong, switch to rgb().
4. Do the colors actually match what Windows Terminal renders? The point of the
   whole exercise is that both machines look identical, especially in tmux and
   nvim. Ground truth for both is `colors/tokyonight_moon.json`.
5. Watch for a **half-applied theme**. `apply_gnome` is deliberately a plain
   sequence of `gsettings set` calls with no guards, because guessing at guards
   from the other machine was not useful. But the script runs under `set -e`, so
   if any one key doesn't exist in this GNOME version, the script aborts
   mid-sequence — leaving `use-theme-colors=false` applied with the palette only
   partly written, which looks worse than either the old or new theme. If that
   happens, restore from the backup (below), then add guards based on what this
   machine actually rejected — not on speculation.

   The one thing already in place is the dconf backup to
   `~/.local/state/dotfiles-gnome-terminal-backup.dconf`, taken before any
   change. Keep it.

To undo anything:

```
dconf load /org/gnome/terminal/legacy/profiles:/ < ~/.local/state/dotfiles-gnome-terminal-backup.dconf
```

Useful reference: the tokyonight plugin ships generated configs for ~45
terminals, including an authoritative GNOME one, at
`~/.local/share/nvim/lazy/tokyonight.nvim/extras/gnome_terminal/tokyonight_moon.dconf`
(only present once nvim has installed plugins).

Report what you changed and what you verified by actually running it.
