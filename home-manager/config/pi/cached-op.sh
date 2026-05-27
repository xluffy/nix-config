#!/usr/bin/env bash
# cached-op.sh - wraps 'op read' with a TTL cache
# Usage: cached-op.sh <op-path> [ttl-hours]
# Example: cached-op.sh "op://private/deepseek-api-key/credential" 4

set -euo pipefail

OP_PATH="${1:?Usage: cached-op.sh <op-path> [ttl-hours]}"
TTL_HOURS="${2:-4}"
CACHE_DIR="${HOME}/.cache/pi-op"
mkdir -p "${CACHE_DIR}"

# Use a hash of the op path as the cache key (avoid special chars in filenames)
CACHE_KEY=$(echo -n "$OP_PATH" | shasum -a 256 | cut -d' ' -f1)
CACHE_FILE="${CACHE_DIR}/${CACHE_KEY}"
CACHE_TS="${CACHE_DIR}/${CACHE_KEY}.ts"

now=$(date +%s)
ttl_seconds=$((TTL_HOURS * 3600))

# Return cached value if still valid
if [[ -f "${CACHE_FILE}" && -f "${CACHE_TS}" ]]; then
  cached_ts=$(cat "${CACHE_TS}")
  age=$((now - cached_ts))
  if [[ $age -lt $ttl_seconds ]]; then
    cat "${CACHE_FILE}"
    exit 0
  fi
fi

# Fetch fresh value from 1Password
if value=$(op read "${OP_PATH}" 2>/dev/null); then
  echo "$value" >"${CACHE_FILE}"
  echo "$now" >"${CACHE_TS}"
  echo "$value"
else
  if [[ -f "${CACHE_FILE}" ]]; then
    cat "${CACHE_FILE}"
    exit 0
  fi
  echo "Error: Failed to read from 1Password and no cached value available" >&2
  exit 1
fi
