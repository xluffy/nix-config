#!/usr/bin/env bash
# cached-op.sh - wraps 'op read' with a TTL cache, or reads from a plaintext file
# Usage:
#   cached-op.sh <op-path>  # 1Password mode
# Examples:
#   cached-op.sh "op://private/deepseek-api-key/credential"

set -euo pipefail

OP_PATH="${1:?Usage: cached-op.sh <op-path>}"

CACHE_DIR="${HOME}/.cache/pi-op"
mkdir -p "${CACHE_DIR}"
FILE_PATH="${CACHE_DIR}/deepseek.key"

DATE=$(date +"%Y-%m-%d")
CACHE_KEY=$(echo -n "${DATE}" | shasum -a 256 | cut -d' ' -f1)
CACHE_FILE="${CACHE_DIR}/${CACHE_KEY}"

_log() {
  printf "\x1B[2;32m"
  echo "[LOG]" "[$(date +'%Y-%m-%d %H:%M:%S')]:" "$*"
  printf "\x1B[0m"
}

_die() {
  printf "\x1B[2;31m"
  echo "[ERROR]" "[$(date +'%Y-%m-%d %H:%M:%S')]:" "$*" >&2
  exit 1
}

_load_cache_file() {
  if [[ -f "${CACHE_FILE}" ]]; then
    cat "${CACHE_FILE}"
    exit 0
  fi
}

main() {
  _load_cache_file

  if [[ -f ${FILE_PATH} ]]; then
    value=$(cat "${FILE_PATH}")
    echo "${value}" >"${CACHE_FILE}"
    _load_cache_file
  elif value=$(op read "${OP_PATH}" 2>/dev/null); then
    echo "${value}" >"${CACHE_FILE}"
    _load_cache_file
  else
    echo "Error: Plaintext file '${FILE_PATH}' not found and no cached value available" >&2
    exit 1
  fi
}

main "$@"
