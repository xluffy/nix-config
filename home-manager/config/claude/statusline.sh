#!/usr/bin/env bash
# Claude Code status line script
# Format: [Model] 📁 project │ 🌿 branch ██████░░ 28% │ $0.83 │ ⏱ 12m 34s ↻89%

input=$(cat)

# ── Model ────────────────────────────────────────────────────────────────────
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')

# ── Project directory (basename of project_dir, fallback to cwd) ─────────────
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // .cwd // ""')
project=$(basename "$project_dir")

# ── Git branch ───────────────────────────────────────────────────────────────
branch=""
if [ -n "$project_dir" ] && [ -d "$project_dir/.git" ]; then
  branch=$(git -C "$project_dir" --git-dir="$project_dir/.git" symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$project_dir" --git-dir="$project_dir/.git" rev-parse --short HEAD 2>/dev/null)
fi

# ── Context progress bar ──────────────────────────────────────────────────────
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
bar=""
if [ -n "$used_pct" ]; then
  # Round to integer
  used_int=$(printf '%.0f' "$used_pct")
  # Build a 12-block bar (each block = ~8.33%)
  total_blocks=12
  filled=$(( used_int * total_blocks / 100 ))
  empty=$(( total_blocks - filled ))
  bar=""
  for ((i=0; i<filled; i++)); do bar="${bar}█"; done
  for ((i=0; i<empty; i++));  do bar="${bar}░"; done
  bar="${bar} ${used_int}%"
fi

# ── Estimated cost (from cumulative token counts) ────────────────────────────
# Pricing approximation for claude-opus-4 class models (per 1M tokens):
#   input: $15, output: $75, cache_write: $18.75, cache_read: $1.50
total_input=$(echo "$input"  | jq -r '.context_window.total_input_tokens  // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
cache_write=$(echo "$input"  | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cache_read=$(echo "$input"   | jq -r '.context_window.current_usage.cache_read_input_tokens     // 0')

cost=$(awk -v ti="$total_input" -v to="$total_output" -v cw="$cache_write" -v cr="$cache_read" \
  'BEGIN { printf "%.2f", (ti*15 + to*75 + cw*18.75 + cr*1.50) / 1000000 }')

# ── Session elapsed time (from transcript file mtime vs now) ─────────────────
elapsed=""
transcript=$(echo "$input" | jq -r '.transcript_path // empty')
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  # Get the oldest (creation) time by checking the directory listing of jsonl entries
  # Approximate: use the mtime of the transcript; subtract from now
  # More accurate: first line timestamp
  first_ts=$(head -1 "$transcript" 2>/dev/null | jq -r '.timestamp // empty' 2>/dev/null)
  if [ -n "$first_ts" ]; then
    now_s=$(date +%s)
    # GNU date or BSD date
    if date --version &>/dev/null 2>&1; then
      start_s=$(date -d "$first_ts" +%s 2>/dev/null)
    else
      start_s=$(date -jf "%Y-%m-%dT%H:%M:%S" "${first_ts%%.*}" +%s 2>/dev/null \
               || date -jf "%Y-%m-%dT%H:%M:%SZ" "${first_ts}" +%s 2>/dev/null)
    fi
    if [ -n "$start_s" ] && [ "$start_s" -gt 0 ] 2>/dev/null; then
      diff=$(( now_s - start_s ))
      mins=$(( diff / 60 ))
      secs=$(( diff % 60 ))
      elapsed=$(printf "%dm %02ds" "$mins" "$secs")
    fi
  fi
fi

# ── Rate limit (5-hour window) ───────────────────────────────────────────────
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rate=""
if [ -n "$five_pct" ]; then
  rate=$(printf '%.0f' "$five_pct")
fi

# ── Assemble output ──────────────────────────────────────────────────────────
parts=()
parts+=("[${model}]")

if [ -n "$project" ]; then
  parts+=("📁 ${project}")
fi

if [ -n "$branch" ]; then
  parts+=("🌿 ${branch}")
fi

if [ -n "$bar" ]; then
  parts+=("${bar}")
fi

if [ -n "$cost" ] && [ "$cost" != "0.00" ]; then
  parts+=("\$${cost}")
fi

if [ -n "$elapsed" ]; then
  parts+=("⏱ ${elapsed}")
fi

if [ -n "$rate" ]; then
  parts+=("↻${rate}%")
fi

# Join with │ separator
result=""
for part in "${parts[@]}"; do
  if [ -z "$result" ]; then
    result="$part"
  else
    result="${result} │ ${part}"
  fi
done

echo "$result"
