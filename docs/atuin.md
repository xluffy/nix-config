# Atuin — Modern Shell History

Atuin replaces bash's native history with an SQLite-backed, auto-deduplicated history database with full-text fuzzy search.

---

## Benefits Over Bash Native History

| Concern | Bash Native | Atuin |
|---|---|---|
| **Storage** | Flat text file (`~/.bash_history`) | SQLite database (`~/.local/share/atuin/history.db`) |
| **Dedup** | `ignoredups` only prevents consecutive in-session dupes; cross-session dupes accumulate forever | SQLite enforces unique entries automatically |
| **Search** | `Ctrl-R` (reverse-i-search) — one match at a time, prefix only | Full-text fuzzy search TUI with preview, stats, and context |
| **Cross-shell sync** | `history -a; history -n` appends duplicates, file grows unbounded | Atomic SQLite transactions, no duplicates |
| **Cross-machine sync** | Manual `scp` or none | `scp` the single SQLite file between machines |
| **Timestamps** | `HISTTIMEFORMAT` embeds epoch lines in text file | Native timestamp column in SQLite |
| **Stats** | `history \| awk` hacks | Built-in: `atuin stats`, top commands, time-of-day heatmaps |
| **Session context** | None | Tracks exit code, duration, CWD, host, session |
| **File size** | Grows linearly, no bound | B-tree index, constant-factor overhead |

---

## Architecture

### Local Storage

```
~/.local/share/atuin/
├── history.db        # SQLite — all commands with timestamps, CWD, host, exit codes
└── key               # local encryption key (auto-generated, unused without cloud sync)
```

Atuin intercepts bash's `preexec`/`precmd` hooks via its bash integration script. Every command you run is captured with:

- **Command text** (deduplicated by content + CWD + host)
- **Timestamp** (epoch)
- **Exit code** (0 = success, non-zero = failure)
- **Duration** (wall-clock seconds)
- **Working directory** (CWD at execution time)
- **Hostname** and **session ID**

### Search Flow

```
  User presses Ctrl-R
        │
        ▼
  ┌─────────────────────┐
  │  Atuin TUI launches  │
  │  (inline overlay)    │
  │                      │
  │  > search query      │  ← fuzzy match across command text
  │  ─────────────────── │
  │  cmd1    (2h ago)    │  ← most relevant first
  │  cmd2    (yesterday) │
  │  cmd3    (3d ago)    │
  └─────────────────────┘
        │
        ▼
  Enter → command inserted at prompt (or executed directly)
  Tab   → paste without running (for editing)
  Esc   → cancel
```

Search modes (`search_mode`):
- `fuzzy` — skim/fzf-style fuzzy matching (default)
- `prefix` — classic bash `Ctrl-R` behavior
- `fulltext` — substring match
- `skim` — skim-style scoring

Filter modes (`filter_mode`):
- `global` — search all history from all directories (default)
- `host` — this machine only
- `session` — current shell session only
- `directory` — current working directory only

### Cross-Machine Sync via SCP

Cloud sync is disabled. History is shared across machines by copying the SQLite database file directly:

```
┌──────────────────────┐         ┌──────────────────────┐
│     MacBook Pro      │         │    Linux / N100      │
│                      │         │                      │
│  ~/.local/share/     │  scp    │  ~/.local/share/     │
│    atuin/history.db  │────────►│    atuin/history.db  │
│                      │         │                      │
│  (primary — writes   │         │  (secondary — reads  │
│   accumulate here)   │         │   primary's history) │
└──────────────────────┘         └──────────────────────┘
```

**One-directional model**: the MacBook is the source of truth. Periodically SCP its `history.db` to the Linux machine. Linux sees MacBook's full history for searching; Linux's own commands stay local to Linux.

This tradeoff keeps things simple — no merge conflicts, no cloud dependency, no encryption keys to manage. The SQLite file is a single self-contained blob.

---

## Onboarding a New Machine

### Prerequisites

Atuin is configured in Home Manager (`modules/programs/atuin.nix`). Apply first:

```bash
just switch
```

### Step 1: Import Existing Bash History

On first run, import your `~/.bash_history` into Atuin's SQLite database:

```bash
atuin import bash
```

Verify it worked:

```bash
atuin stats
```

### Step 2: Sync History from Primary Machine

If this is the **secondary machine** (Linux), pull the primary's database:

```bash
# Pull history.db from MacBook
scp quang.van.nguyen@macbook:~/.local/share/atuin/history.db \
    ~/.local/share/atuin/history.db
```

After the copy, the secondary machine can search the primary's full history immediately — no restart needed, `Ctrl-R` picks it up on next use.

If this is the **primary machine** (MacBook), skip this step — your history already lives there.

### Step 3: Periodic Resync

Set up a cron job or systemd timer on the Linux machine to pull updates regularly:

```bash
# Pull updated history from MacBook every night
0 2 * * * scp quang.van.nguyen@macbook:~/.local/share/atuin/history.db ~/.local/share/atuin/history.db
```

Or just run it manually when you want to refresh:

```bash
atuin-pull() {
  scp quang.van.nguyen@macbook:~/.local/share/atuin/history.db \
      ~/.local/share/atuin/history.db
}
```

### Useful Commands

```bash
atuin stats            # history statistics (top commands, heatmaps, time-of-day)
atuin search <query>   # search from command line (no TUI, prints matches)
atuin history list     # list recent entries with timestamps
atuin history start    # start a new session marker
atuin history end      # end current session marker
```

### Troubleshooting

**Atuin doesn't intercept Ctrl-R after switch?**
Open a new terminal tab or run `exec bash`. The bash integration hooks are loaded at shell init.

**Search returns no results?**
Make sure you imported history: `atuin import bash`. Check the DB: `atuin stats` should show a non-zero command count.

**SCP'd DB doesn't show new entries?**
Atuin caches the DB in memory. `exec bash` to reload, or just start typing — `Ctrl-R` reopens the TUI with fresh data.

**Tab to edit does not work (empties the command line)?**
This occurs on macOS if you are using the system default `/bin/bash` which is **version 3.2.57** (released in 2006). Atuin's command injection relies on `READLINE_LINE` and `READLINE_POINT` variables, which are only supported in **Bash 4.0+**. 
To fix this, permanently change your default login shell to the Nix-installed Bash 5.2+:
1. Whitelist the Nix Bash binary path:
   ```bash
   echo "$HOME/.nix-profile/bin/bash" | sudo tee -a /etc/shells
   ```
2. Change your default login shell:
   ```bash
   chsh -s "$HOME/.nix-profile/bin/bash"
   ```
3. Open a new terminal tab/window and verify with `echo $BASH_VERSION`.

**`stty: 'standard input': unable to perform all requested operations` after Ctrl+R → Enter?**
This is a known issue with `enter_accept = true` on macOS (especially inside tmux). The error is harmless — your command still runs correctly — but the noise is annoying.

### Root Cause

When `enter_accept = true`, atuin uses its own `__atuin_accept_line` function to execute the selected command instead of pasting it into readline. This function juggles terminal settings to ensure the command runs in the right terminal mode:

```bash
# __atuin_accept_line (simplified flow):
__atuin_stty_backup=$(stty -g)    # 1. Save current terminal state
stty "$ATUIN_STTY"                # 2. Restore to shell-init state
eval -- "$__atuin_command"         # 3. Run your command (e.g., vim)
stty "$__atuin_stty_backup"        # 4. Restore pre-command state ← ERROR HERE
```

The failure at step 4 occurs because after a fullscreen TUI program (vim, less, tmux popup) exits, the BSD terminal driver on macOS is in a state where some flags in the saved `stty -g` string cannot be cleanly reapplied. The nested PTY layers (tmux → bash → atuin TUI → your command) exacerbate this.

### Fix A: Disable `enter_accept` (Recommended, Current Config)

Set `enter_accept = false` in `programs/atuin.nix`:

```nix
settings = {
  enter_accept = false;  # Paste into readline, avoid __atuin_accept_line entirely
};
```

With this setting:
- Atuin pastes the selected command into your prompt (like normal Ctrl-R)
- You press Enter manually — bash handles execution normally
- `__atuin_accept_line` never runs, no stty juggling, no error
- UX difference: you see the command appear on the prompt line before it runs, instead of executing immediately

### Fix B: stty Wrapper (If You Want `enter_accept = true`)

If you prefer instant execution on Enter, keep `enter_accept = true` and add a `stty` wrapper to `modules/shell/function.sh` that filters the benign error:

```bash
# Wrap stty to suppress benign "unable to perform all requested operations"
# noise from atuin's terminal juggling after fullscreen commands (e.g., vim).
stty() {
  local _tmp _ret
  _tmp=$(command stty "$@" 2>&1)
  _ret=$?
  if [[ $_ret -ne 0 ]]; then
    if [[ $_tmp != *"unable to perform all requested operations"* ]]; then
      printf '%s\n' "$_tmp" >&2
    fi
  elif [[ -n $_tmp ]]; then
    printf '%s\n' "$_tmp"
  fi
  return $_ret
}
```

How it works:
- `stty -g` (read): stdout passes through normally → `ATUIN_STTY=$(stty -g)` still works
- `stty "$SETTINGS"` (write, success): silent (no output)
- `stty "$SETTINGS"` (write, known noise): error suppressed
- `stty "$SETTINGS"` (write, real error): stderr still passes through
- Exit codes preserved for all cases

To switch back to `enter_accept = true`:
1. Add the wrapper above to `modules/shell/function.sh`
2. Set `enter_accept = true` in `modules/programs/atuin.nix`
3. Run `just switch`

