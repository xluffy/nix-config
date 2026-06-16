#!/usr/bin/env bash
set -uo pipefail

STATUS_JSON="$(cat)"
readonly STATUS_JSON

parse_json() {
  jq -r '
    [
      (.model.display_name // "Claude"),
      (.workspace.project_dir // .cwd // ""),
      (.context_window.used_percentage // "" | tostring),
      (.context_window.total_input_tokens // 0 | tostring),
      (.context_window.total_output_tokens // 0 | tostring),
      (.context_window.current_usage.cache_creation_input_tokens // 0 | tostring),
      (.context_window.current_usage.cache_read_input_tokens // 0 | tostring),
      (.transcript_path // ""),
      (.rate_limits.five_hour.used_percentage // "" | tostring)
    ] | @tsv
  ' <<<"${STATUS_JSON}"
}

build_progress_bar() {
  local used_pct_str="$1" used_int filled empty
  [[ -z "${used_pct_str}" ]] && return
  used_int="$(printf '%.0f' "${used_pct_str}")"
  filled=$((used_int * 12 / 100))
  empty=$((12 - filled))
  printf '%s%s %d%%' \
    "$(printf '%*s' "${filled}" '' | tr ' ' '█')" \
    "$(printf '%*s' "${empty}" '' | tr ' ' '░')" \
    "${used_int}"
}

calculate_cost() {
  awk -v ti="$1" -v to="$2" -v cw="$3" -v cr="$4" \
    'BEGIN { printf "%.2f", (ti*15 + to*75 + cw*18.75 + cr*1.50) / 1000000 }'
}

parse_iso8601_to_epoch() {
  local ts="$1" epoch
  if date --version &>/dev/null 2>&1; then
    epoch="$(date -d "${ts}" +%s 2>/dev/null)"
  else
    epoch="$(date -jf "%Y-%m-%dT%H:%M:%S" "${ts%%.*}" +%s 2>/dev/null)"
    [[ -z "${epoch}" ]] && epoch="$(date -jf "%Y-%m-%dT%H:%M:%SZ" "${ts}" +%s 2>/dev/null)"
  fi
  printf '%s' "${epoch:-0}"
}

get_elapsed() {
  local transcript_path="$1" first_ts start_s now_s diff mins secs
  [[ -z "${transcript_path}" || ! -f "${transcript_path}" ]] && return
  first_ts="$(head -1 "${transcript_path}" 2>/dev/null | jq -r '.timestamp // empty' 2>/dev/null)"
  [[ -z "${first_ts}" ]] && return
  now_s="$(date +%s)"
  start_s="$(parse_iso8601_to_epoch "${first_ts}")"
  [[ "${start_s}" -le 0 ]] && return
  diff=$((now_s - start_s))
  mins=$((diff / 60))
  secs=$((diff % 60))
  printf '%dm %02ds' "${mins}" "${secs}"
}

get_branch() {
  local project_dir="$1" branch
  [[ -n "${project_dir}" && -d "${project_dir}/.git" ]] || return
  branch="$(git -C "${project_dir}" --git-dir="${project_dir}/.git" symbolic-ref --short HEAD 2>/dev/null)"
  [[ -n "${branch}" ]] || branch="$(git -C "${project_dir}" --git-dir="${project_dir}/.git" rev-parse --short HEAD 2>/dev/null)"
  printf '%s' "${branch}"
}

join_parts() {
  local IFS=' │ '
  printf '%s' "$*"
}

main() {
  local model_name project_dir used_pct_str total_input total_output cache_write cache_read transcript_path rate_str
  IFS=$'\t' read -r model_name project_dir used_pct_str total_input total_output cache_write cache_read transcript_path rate_str <<<"$(parse_json)"

  local model project branch bar cost elapsed rate parts
  model="[${model_name}]"
  project="$(basename "${project_dir}")"
  branch="$(get_branch "${project_dir}")"
  bar="$(build_progress_bar "${used_pct_str}")"
  cost="$(calculate_cost "${total_input}" "${total_output}" "${cache_write}" "${cache_read}")"
  elapsed="$(get_elapsed "${transcript_path}")"

  parts=("${model}")

  [[ -n "${project}" ]] && parts+=("📁 ${project}")
  [[ -n "${branch}" ]] && parts+=("🌿 ${branch}")
  [[ -n "${bar}" ]] && parts+=("${bar}")
  [[ -n "${cost}" && "${cost}" != "0.00" ]] && parts+=("\$${cost}")
  [[ -n "${elapsed}" ]] && parts+=("⏱ ${elapsed}")

  if [[ -n "${rate_str}" ]]; then
    rate="$(printf '%.0f' "${rate_str}")"
    parts+=("↻${rate}%")
  fi

  join_parts "${parts[@]}"
}

main
