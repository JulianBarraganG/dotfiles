#!/usr/bin/env bash
# Slowly pulse the windows that claude-flag.sh has flagged.
#
# Started by claude-flag.sh when @claude-blink is 'on', and exits by itself once
# no window carries a flag, so nothing is left running in the background. A
# second instance exits immediately.
#
# It toggles one global option, @claude_blink_phase, which the window-status
# formats in tmux.conf read. Because it never writes per-window state, it cannot
# fight with a flag being set or cleared underneath it.

set -u
exec >/dev/null 2>&1

command -v tmux >/dev/null || exit 0

lock=${TMPDIR:-/tmp}/claude-tmux-blink-$(id -u).lock
if ! mkdir "$lock" 2>/dev/null; then
    pid=$(cat "$lock/pid" 2>/dev/null)
    if [ -n "${pid:-}" ] && kill -0 "$pid" 2>/dev/null; then
        exit 0                      # already pulsing
    fi
    rm -rf "$lock"                  # stale lock left by a killed blinker
    mkdir "$lock" 2>/dev/null || exit 0
fi
echo $$ >"$lock/pid"

cleanup() {
    tmux set -gu @claude_blink_phase 2>/dev/null
    tmux refresh-client -S 2>/dev/null
    # Only release a lock that is still ours, so an exiting instance cannot
    # delete the lock a newly started one has just taken.
    [ "$(cat "$lock/pid" 2>/dev/null)" = "$$" ] && rm -rf "$lock"
}
trap cleanup EXIT
trap 'exit 0' INT TERM      # must exit; a returning handler resumes the loop

interval=$(tmux show -gqv @claude-blink-interval)
[ -n "$interval" ] || interval=0.6

phase=0
while tmux list-windows -a -F '#{@claude_flag}' 2>/dev/null | grep -q .; do
    phase=$((1 - phase))
    tmux set -g @claude_blink_phase "$phase"
    tmux refresh-client -S
    sleep "$interval"
done
