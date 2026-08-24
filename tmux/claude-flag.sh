#!/usr/bin/env bash
# Colour a tmux window when the Claude Code session running in it wants
# attention, so several parallel sessions can be watched from the status bar.
#
#   claude-flag.sh done             green  — Claude finished its turn
#   claude-flag.sh wait             orange — Claude is blocked on you, or idle
#   claude-flag.sh clear [window]   back to the normal palette
#
# Called by claude-watch.sh, which passes the pane via $TMUX_PANE, and by the
# tmux hooks in tmux.conf, which pass a window id explicitly. The Stop and
# Notification hooks in ~/.claude/settings.json call it the same way and are
# left in place, but org policy (disableAllHooks) means they never run.
#
# All this does is set two window-local options; the window-status formats in
# tmux.conf turn those into colours. Nothing here touches a style, so a flag
# can never leave a colour stuck behind.
#
# Silent by design: a UserPromptSubmit hook's stdout is fed back into Claude's
# context, so this must never print anything.

set -u
exec >/dev/null 2>&1

action=${1:-}
window=${2:-}

# Optional trace, to confirm Claude Code really is invoking this script and with
# what environment. Turn it on by creating the file, off by deleting it:
#   touch ~/.claude/claude-flag.debug
# Gated on a file rather than a tmux option so it still records a call that
# arrives with no $TMUX at all, which is one of the things worth diagnosing.
debug=$HOME/.claude/claude-flag.debug
if [ -e "$debug" ]; then
    tmuxenv=unset; [ -n "${TMUX:-}" ] && tmuxenv=set
    printf '%s action=%-6s TMUX=%-5s TMUX_PANE=%s\n' \
        "$(date '+%H:%M:%S')" "${action:-none}" "$tmuxenv" "${TMUX_PANE:-unset}" \
        >>"$debug"
fi

command -v tmux >/dev/null || exit 0
[ -n "${TMUX:-}" ] || exit 0        # nothing to flag when not running under tmux

# Act on the window a tmux hook named, else the one holding this Claude session.
if [ -z "$window" ]; then
    [ -n "${TMUX_PANE:-}" ] || exit 0
    window=$(tmux display-message -p -t "$TMUX_PANE" '#{window_id}') || exit 0
fi
[ -n "$window" ] || exit 0

# Setting a window option does not by itself repaint the status bar, so ask for a
# redraw explicitly; without this a flag only appears at the next status-interval.
flag_off() {
    tmux set -uw -t "$window" @claude_flag
    tmux set -uw -t "$window" @claude_state
    tmux refresh-client -S
}

# Pulsing only runs while something is flagged, and a second instance is a no-op,
# so it is safe to try to start one on every flag.
start_blinker() {
    local blinker=${BASH_SOURCE[0]%/*}/claude-blink.sh
    [ -x "$blinker" ] || return 0
    setsid "$blinker" &
}

flag_on() {
    local state=$1 palette=$2 fallback=$3 colour

    # Every window gets flagged, including the one you are currently viewing: the
    # bar is the thing you glance at, so a session that finished should show up
    # there whether or not you happen to be sitting on it. The active window keeps
    # its bold attribute, so "you are here" is still legible while it is coloured.

    # tmux does not expand #{@claude_flag} recursively, so resolve the palette
    # entry to a literal colour before storing it.
    colour=$(tmux show -gqv "$palette")
    [ -n "$colour" ] || colour=$fallback

    tmux set -w -t "$window" @claude_state "$state"
    tmux set -w -t "$window" @claude_flag "$colour"
    tmux refresh-client -S

    [ "$(tmux show -gqv @claude-blink)" = "on" ] && start_blinker
    return 0
}

case $action in
    done)  flag_on done "@green"  "green"  ;;
    wait)  flag_on wait "@orange" "yellow" ;;
    clear) flag_off ;;
esac
exit 0
