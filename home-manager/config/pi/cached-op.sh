#!/usr/bin/env bash
# cached-op.sh - wraps 'op read' with a TTL cache, or reads from a plaintext file
# Usage:
#   cached-op.sh <op-path> [ttl-hours]                        # 1Password mode
#   cached-op.sh --file <plaintext-file-path> [ttl-hours]     # plaintext file mode (Ubuntu server, no op CLI)
# Examples:
#   cached-op.sh "op://private/deepseek-api-key/credential" 4
#   cached-op.sh --file ~/.cache/pi-op/deepseek.key 4

set -euo pipefail

FILE_MODE=false
OP_PATH=""
FILE_PATH=""

# Parse arguments
if [[ "${1:-}" == "--file" ]]; then
  FILE_MODE=true
  FILE_PATH="${2:?Usage: cached-op.sh --file <plaintext-file-path> [ttl-hours]}"
  TTL_HOURS="${3:-4}"
else
  OP_PATH="${1:?Usage: cached-op.sh <op-path> [ttl-hours]}"
  TTL_HOURS="${2:-4}"
fi

CACHE_DIR="${HOME}/.cache/pi-op"
mkdir -p "${CACHE_DIR}"

# Use a hash of the source identifier as the cache key (avoid special chars in filenames)
if $FILE_MODE; then
  CACHE_SOURCE="file:${FILE_PATH}"
else
  CACHE_SOURCE="op:${OP_PATH}"
fi
CACHE_KEY=$(echo -n "$CACHE_SOURCE" | shasum -a 256 | cut -d' ' -f1)
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

# Fetch fresh value
if $FILE_MODE; then
  # Read from plaintext file (e.g., Ubuntu server without 1Password CLI)
  if [[ -f "${FILE_PATH}" ]]; then
    value=$(cat "${FILE_PATH}")
    echo "$value" >"${CACHE_FILE}"
    echo "$now" >"${CACHE_TS}"
    echo "$value"
  else
    if [[ -f "${CACHE_FILE}" ]]; then
      cat "${CACHE_FILE}"
      exit 0
    fi
    echo "Error: Plaintext file '${FILE_PATH}' not found and no cached value available" >&2
    exit 1
  fi
else
  # Fetch from 1Password
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
fi
