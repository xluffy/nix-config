---
name: bash-scripting
description: Guidelines for developing clean, maintainable bash/shell scripts. Focus on automation tasks, Unix philosophy, POSIX compatibility, Debian/Ubuntu and RHEL/CentOS based systems. Use when user asks to create or review bash/shell scripts.
---

## When to Use Shell

Shell is the right tool for:

- Gluing together CLI tools (`gsutil`, `psql`, `curl`, `find`, …)
- File-system operations, backups, data pipelines
- Simple automation with linear or branching control flow
- Prototyping commands before porting to a compiled language

**Switch to Python/Go/Rust when** you need arrays-of-arrays, hash maps with complex values, JSON manipulation beyond `jq`, or concurrency. Shell is an *orchestrator*, not a data-processing language.

## Which Shell

Target **bash** (not `sh`, not `zsh`). Bash gives us `[[ ]]`, arrays, `readarray`, `local -n`, and `%(...)T` in `printf`. Scripts run on Debian/Ubuntu (bash at `/bin/bash`) and RHEL/CentOS — always invoke via `env` for portability.

## Script Structure

Every script follows this skeleton:

```bash
#!/usr/bin/env bash
# script_name.sh — One-line description of what this script does.
#
# Usage:  ./script_name.sh [options]
#
# Dependencies: cmd1, cmd2
# Side effects: writes to /some/path, modifies /etc/foo

set -uo pipefail

# ---- constants ---------------------------------------------------------------

readonly CONFIG_DIR="/etc/myapp"
# … runtime-computed constants locked immediately, see §Naming Conventions

# ---- helpers -----------------------------------------------------------------
# Small, reusable utility functions (logging, cleanup, validation)

# ---- functions ---------------------------------------------------------------
# Domain functions, grouped by concern

# ---- main --------------------------------------------------------------------
# Entry point; always the last function defined

main() {
  # …
}

main "$@"
```

### Shebang

Always `#!/usr/bin/env bash`. Hardcoding `/bin/bash` breaks on systems where bash lives elsewhere (NixOS, BSD, some container images).

### Strict Mode

```bash
set -uo pipefail
```

- `-u` — reject undefined variables (catches typos early)
- `-o pipefail` — a pipeline fails if *any* command in it fails

**Do not use `set -e`** (errexit). It has surprising edge cases: it does not trigger inside `(( ))` evaluating to 0, inside `let`, or when a failing command is the condition of `if`/`while`/`||`/`&&`. It also turns off inside subshells. Explicit error checks are predictable; `set -e` is not.

Use `set -x` for interactive debugging only. Do not commit it.

### File Extensions

Executable scripts: no `.sh` extension. Libraries meant to be sourced: `.sh` extension.

### File Ordering

Constants → helpers → domain functions → `main`. No executable code between function definitions. This makes the file scannable and avoids surprises when debugging.

### main()

Required for any script with at least one other function. `main` is always the last function. The final non-comment line is:

```bash
main "$@"
```

This gives you `local` variables in the main flow and a consistent entry-point pattern across all scripts.

## Naming Conventions

### Function Names

Lowercase, underscores to separate words:

```bash
backup_database() { … }
validate_input() { … }
```

The `function` keyword is optional, but prefer never use this keyword.

Braces on the **same line** as the function name. No space between name and `()`:

```bash
# Correct
my_func() {
  …
}

# Wrong
my_func ()
{
  …
}
```

### Variable Names

Lowercase with underscores. Loop variables use the **singular form** of the collection name:

```bash
for zone in "${zones[@]}"; do
  process_zone "${zone}"
done
```

No accept single-letter (`i`, `j`)

### Constants and Environment Variables

`UPPER_CASE` with underscores. Declare with `readonly` (preferred) or `declare -r`:

```bash
readonly CONFIG_DIR="/etc/myapp"
readonly MAX_RETRIES=5
```

For values computed at runtime, make them `readonly` **immediately after assignment**:

```bash
TODAY="$(date +%Y-%m-%d)"
BACKUP_DIR="/data/${TODAY}"
readonly TODAY BACKUP_DIR
```

For environment variables, use `export` followed by `readonly`, or `declare -xr`:

```bash
export AWS_REGION="ap-southeast-1"
readonly AWS_REGION
```

### Source Filenames

Lowercase with underscores: `backup_database.sh`, `rotate_logs.sh`. No hyphens.

## Variables and Quoting

### Always Quote

```bash
# Correct
process_file "${input_file}"
cp "${src}" "${dst}"

# Wrong — word splitting, globbing
process_file ${input_file}
```

Array expansions always use the quoted form:

```bash
"${array[@]}"    # each element as a separate word — this is 99% of cases
"${array[*]}"    # all elements as a single string (rarely what you want)
```

### No Quoting Needed Inside `[[ ]]`

```bash
[[ -f ${config} ]]         # fine, no word splitting inside [[ ]]
[[ ${name} == "admin" ]]   # fine
```

However, the right-hand side of `==` / `!=` in `[[ ]]` **is** a pattern when unquoted:

```bash
[[ ${filename} == *.log ]]  # pattern match — "ends with .log"
[[ ${filename} == "*.log" ]] # literal string "*.log"
```

Be intentional about which you mean.

### Default Values

```bash
dir="${1:-/tmp}"             # use $1, fallback to /tmp
name="${USER:-unknown}"      # use $USER, fallback to "unknown"
count="${count:=0}"          # if unset or empty, assign "0"
```

### Within `$(( ))`, Omit `${}`

```bash
# Prefer
(( i += 3 ))
echo "$(( hr * 3600 + min * 60 + sec ))"

# Still works but noisy
(( ${i} += 3 ))
```

This is the one place where bare variable names are both safe and clearer.

## Conditionals and Testing

### Use `[[ ]]` Over `[ ]`

`[[ ]]` is a bash keyword that avoids word splitting, supports `=~` regex matching, and allows `&&` / `||` inside the test:

```bash
if [[ -f "${path}" && -r "${path}" ]]; then
  process "${path}"
fi
```

### Equality: `==` Over `=`

```bash
[[ "${name}" == "admin" ]]   # preferred — clearly a comparison, not an assignment
[[ "${name}" = "admin" ]]    # works but avoid
```

### Empty / Non-Empty Tests

Be explicit — use `-z` (zero-length) and `-n` (non-zero-length):

```bash
# Preferred — intent is obvious
if [[ -z "${value}" ]]; then … fi
if [[ -n "${value}" ]]; then … fi

# Avoid — implicit, easy to misread
if [[ "${value}" ]]; then … fi
if [[ ! "${value}" ]]; then … fi
```

### Numeric Comparisons

**Never** use `<` `>` inside `[[ ]]` — they perform **lexicographic** comparison (so `"22" < "3"` is true!).

Use `(( ))` for arithmetic tests, or `-lt` `-gt` `-le` `-ge` `-eq` `-ne` inside `[[ ]]`:

```bash
# Correct
if (( count > 3 )); then … fi
if [[ "${count}" -gt 3 ]]; then … fi

# Wrong — lexicographic, not numeric
if [[ "${count}" > 3 ]]; then … fi
```

### Pattern and Regex Matching

```bash
# Glob pattern (RHS unquoted)
if [[ "${filename}" == *.log ]]; then … fi

# Regex (use =~, RHS unquoted)
if [[ "${version}" =~ ^v[0-9]+\.[0-9]+$ ]]; then … fi
```

### Predicate Functions

Encapsulate repeated conditions:

```bash
is_readable_file() { [[ -f "$1" && -r "$1" ]]; }

is_readable_file "${input}" || die "Cannot read: ${input}"
```

## Functions

### Definition

```bash
func_name() {
  local var="value"
  …
}
```

- `() {` on the same line, no space before `(`
- Closing `}` on its own line

### Local Variables

Every variable inside a function **must** be declared `local`. This prevents polluting the global namespace.

**Critical rule**: separate `local` declaration from `$(…)` assignment. `local` swallows the command's exit code:

```bash
# Correct — exit code of my_func is preserved
my_function() {
  local result
  result="$(my_func)" || return
  …
}

# Wrong — $? is always 0 (the exit code of `local`, not `my_func`)
my_function() {
  local result="$(my_func)"
  (( $? == 0 )) || return   # this check is useless!
  …
}
```

### Return Values

- `return 0` for success, `return N` (1–255) for failure
- Predicate functions: return status only, print nothing
- Data output: print to stdout, capture with `$()`:

```bash
get_timestamp() { date +%Y%m%d-%H%M%S; }
backup_name="backup-$(get_timestamp).tar.gz"
```

For performance-critical code (tight loops), use `local -n` (nameref) to avoid subshell overhead. Otherwise, `$()` is preferred for readability.

### Single Responsibility

One function, one job. If a function does "export, compress, AND upload", split it into `_export`, `_compress`, `_upload`.

## Error Handling

### Error-First Pattern

Use explicit checks rather than `set -e`. The error-first pattern handles failures immediately and keeps the happy path flat:

```bash
[[ -f "${config_file}" ]] || die "Config not found: ${config_file}"
[[ -r "${config_file}" ]] || die "Config not readable: ${config_file}"
cd "${work_dir}" || die "Cannot enter: ${work_dir}"
```

### Checking Command Exit Status

```bash
# Preferred — check directly in if/||
if ! mv "${files[@]}" "${dest}/"; then
  die "Cannot move files to ${dest}"
fi

# Also acceptable — explicit $? check
mv "${files[@]}" "${dest}/"
if (( $? != 0 )); then
  die "Cannot move files to ${dest}"
fi
```

### PIPESTATUS

`PIPESTATUS` is overwritten by **every subsequent command** (including `[` and `echo`). Capture it immediately:

```bash
tar -cf - ./* | ( cd "${dest}" && tar -xf - )
return_codes=("${PIPESTATUS[@]}")
if (( return_codes[0] != 0 )); then
  die "tar create failed"
fi
if (( return_codes[1] != 0 )); then
  die "tar extract failed"
fi
```

### Don't Mask Failures in Pipelines

With `set -o pipefail`, a pipeline fails if any component fails:

```bash
# If grep fails, the pipeline fails — good
grep "ERROR" /var/log/app.log | wc -l
```

## Arithmetic

Use `(( … ))` for arithmetic evaluation and `$(( … ))` for expansion:

```bash
# Evaluation (no $)
(( i += 3 ))
if (( a < b )); then … fi

# Expansion (with $) — inside strings or assignments
echo "$(( 2 + 2 )) is 4"
total="$(( price * quantity ))"
```

### Never Use

- `let` — subject to word splitting, non-obvious
- `$[ … ]` — deprecated, non-portable
- `expr` — external process, slow, quoting headaches

```bash
# Wrong
let i="2 + 2"
i=$[2 * 10]
i=$(expr 4 + 4)
```

### Trap: `set -e` and `(( ))`

With `set -e` enabled (which we avoid), `(( 0 ))` evaluates to 1 and **causes the script to exit**. Since we don't use `set -e`, this isn't a concern, but be aware when reading others' scripts.

## Arrays

Use arrays for lists of arguments, file paths, or any collection of strings. Never concatenate arguments into a single string:

```bash
# Correct — array
declare -a rsync_flags
rsync_flags=(--archive --compress --delete)
rsync_flags+=(--exclude='*.tmp')
rsync "${rsync_flags[@]}" "${src}/" "${dst}/"

# Wrong — string masquerading as list
rsync_flags="--archive --compress --delete"
rsync_flags+=" --exclude='*.tmp'"   # quoting nightmare
rsync ${rsync_flags} "${src}/" "${dst}/"  # word splitting, globbing bugs
```

### Expansion Forms

```bash
"${arr[@]}"    # each element as a separate, quoted word ← use this
"${arr[*]}"    # all elements joined into one string (rare)
${#arr[@]}    # array length
```

### Command Substitution Does Not Return Arrays

```bash
# Wrong — word splitting, globbing on output
declare -a files=($(ls /tmp))

# Correct
readarray -t files < <(find /tmp -type f)
```

## Pipes and Subshells

### The Pipe-to-While Subshell Trap

Pipes create subshells. Variables modified inside a pipe are **lost** when the pipe ends:

```bash
# Wrong — last_line is always 'NULL'
last_line='NULL'
your_command | while read -r line; do
  last_line="${line}"
done
echo "${last_line}"   # prints 'NULL'
```

### Solutions

**Process substitution** — redirect into `while` without piping:

```bash
last_line='NULL'
while read -r line; do
  last_line="${line}"
done < <(your_command)
echo "${last_line}"   # correct
```

**readarray** — read entire output into an array, then iterate:

```bash
readarray -t lines < <(your_command)
for line in "${lines[@]}"; do
  process "${line}"
done
```

### `for var in $(cmd)` Splits on Whitespace

```bash
# Wrong — splits on any whitespace, globs filenames
for file in $(find . -name '*.txt'); do … done

# Correct
while IFS= read -r file; do
  …
done < <(find . -name '*.txt')
```

## Command Substitution

Use `$(…)` — never backticks. Backticks don't nest cleanly and are hard to read:

```bash
# Correct
var="$(command "$(command1)")"

# Wrong
var="`command \`command1\``"
```

### Check Exit Status

When a command substitution can fail, capture and check:

```bash
output="$(risky_command)" || die "risky_command failed"
```

### Don't Capture Stderr Into Substitution

```bash
# stderr goes to caller's stderr, stdout captured — good
result="$(cmd)"

# stderr mixed into result — usually wrong
result="$(cmd 2>&1)"
```

## Builtins Over External Commands

Prefer bash builtins — they are faster and avoid spawning processes:

| Instead of                          | Use bash builtin                    |
|-------------------------------------|-------------------------------------|
| `$(echo "${str}" \| sed 's/^foo/bar/')` | `"${str/#foo/bar}"`            |
| `$(echo "${str}" \| sed 's/foo$/bar/')` | `"${str/%foo/bar}"`            |
| `$(echo "${str}" \| grep -oP 'pat')`    | `[[ "${str}" =~ pat ]]` + `BASH_REMATCH` |
| `$(expr 4 + 4)`                     | `$(( 4 + 4 ))`                     |
| `$(basename "${path}")`             | `"${path##*/}"`                    |
| `$(dirname "${path}")`              | `"${path%/*}"`                     |
| `$(date +%s)`                       | `printf '%(%s)T' -1`               |

```bash
# Correct — all builtin, zero subshells
path="/var/log/app.log"
name="${path##*/}"                    # "app.log"
dir="${path%/*}"                      # "/var/log"
timestamp="$(printf '%(%Y%m%d-%H%M%S)T' -1)"

# Wrong — 3 extra processes
name=$(basename "${path}")
dir=$(dirname "${path}")
timestamp=$(date +%Y%m%d-%H%M%S)
```

## Logging and Output

### Logging Helpers

Define helpers for consistent, timestamped logging:

```bash
_log() {
  printf '\x1B[2;32m[LOG] [%(%Y-%m-%d %H:%M:%S)T]: %s\x1B[0m\n' -1 "$*"
}

_die() {
  printf '\x1B[2;31m[ERROR] [%(%Y-%m-%d %H:%M:%S)T]: %s\x1B[0m\n' -1 "$*" >&2
  exit 1
}
```

Key points:
- `_log` writes to stdout; `_die` writes to stderr with `>&2`
- Use `printf`, not `echo` — `echo` varies across shells with `-n`, `-e`, backslashes
- `%()T` with `-1` is bash builtin `printf` time formatting — avoids a `date` subshell

### stdout vs stderr

- **stdout** (fd 1): data output — what your script produces
- **stderr** (fd 2): diagnostics, errors, progress messages

Keep stdout clean for piping and command substitution:

```bash
generate_report > report.txt   # only report data goes to file
generate_report 2> errors.log  # diagnostics go to error log
```

### Indentation and Formatting

- **2 spaces** per indent level. No tabs.
- Closing keywords on their own line: `fi`, `done`, `esac`, `}`

## Wildcards and Globs

### Always Prefix with `./`

Filenames can start with `-`, which commands interpret as flags:

```bash
# Dangerous — if any file starts with '-', it becomes an rm flag
rm -v *

# Safe — './-f' is a filename, not a flag
rm -v ./*
```

### Quote Loop Variables

```bash
for file in ./*.txt; do
  process "${file}"
done
```

### Handle Empty Globs

By default, an unmatched glob is passed literally (e.g., `*.txt` when no `.txt` files exist). Use `shopt -s nullglob` to make unmatched globs expand to nothing, or check before iterating:

```bash
shopt -s nullglob
files=(./*.log)
if (( ${#files[@]} == 0 )); then
  _log "No log files found"
  return 0
fi
for file in "${files[@]}"; do
  rotate "${file}"
done
```

## Iteration

### Forwarding Arguments

Always quote `"$@"` — each argument stays intact:

```bash
wrapper() {
  actual_command "${@}"
}
```

### Loop Over Explicit Lists

```bash
for env in staging production; do
  deploy "${env}"
done
```

### Iterate Safely Over Command Output

```bash
while IFS= read -r line; do
  process "${line}"
done < <(some_command)
```

`IFS=` preserves leading/trailing whitespace. `-r` prevents backslash interpretation.

## Comments

### File Header

Every script starts with a header block:

```bash
#!/usr/bin/env bash
# script_name.sh — One-line description.
#
# Usage:  ./script_name.sh <arg1> [arg2]
#
# Dependencies: curl, jq, gsutil
# Side effects: writes to /tmp/foo, modifies ~/.config/bar
```

### Function or Implementation Comments

Less comments, code is documentation, no need explain again

### TODO Comments

```bash
# TODO(quang): retry with backoff for transient GCS errors
```

Use `# TODO(username): description` format.

## ShellCheck

Run [ShellCheck](https://shellcheck.net) on every script. It catches common bugs:

- Unquoted variables
- `$?` misuse
- `read` without `-r`
- Unused variables
- `cd` without error checking

```bash
shellcheck script_name.sh
```

Aim for zero warnings. If you must suppress a specific warning, add a comment with justification:

```bash
# shellcheck disable=SC2034  # kept for documentation
readonly OLD_API_ENDPOINT="https://v1.example.com"
```

## Compatibility & Portability

### Target Bash, Not sh

Do not write `#!/bin/sh` scripts. Use bash features freely:

- `[[ ]]` for conditionals
- Arrays and `readarray`
- `local`, `local -n`
- `printf '%()T'` for timestamps
- `shopt`
- Process substitution `< <(cmd)`

### Distribution Notes

These scripts target **Debian/Ubuntu** and **RHEL/CentOS** systems. Key differences to watch:

| Concern | Debian/Ubuntu | RHEL/CentOS |
|---------|---------------|-------------|
| `bash` path | `/bin/bash` | `/bin/bash` |
| Package manager | `apt-get` / `dpkg` | `yum` / `dnf` / `rpm` |
| Service manager | `systemctl` | `systemctl` |
| Default `find` | GNU find | GNU find |

Use `#!/usr/bin/env bash` and avoid distro-specific commands inside scripts unless truly necessary.

## Avoid / Anti-Patterns

| Anti-pattern | Do this instead |
|---|---|
| `eval` | Use arrays, indirect variables, or refactor |
| Parsing `ls` output | Use globs or `find` |
| Unquoted expansions | Always quote `"${var}"` |
| `set -e` | Explicit `|| die` / `|| return` checks |
| Aliases in scripts | Use functions |
| `let`, `$[...]`, `expr` | `(( … ))` / `$(( … ))` |
| Backticks for command substitution | `$( … )` |
| `echo` for output | `printf` |
| Concatenated strings for argument lists | Arrays `"${arr[@]}"` |
| `for var in $(cmd)` | `while read` or `readarray` |
| `[ … ]` single brackets | `[[ … ]]` |
| Comments that repeat the code | Comments that explain **why** |
| Hardcoded `/bin/bash` | `#!/usr/bin/env bash` |
| `$?` checked too late | Check immediately, or use `if cmd; then` |
| Pipes to `while` | Process substitution `< <(cmd)` |
