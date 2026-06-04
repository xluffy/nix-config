#!/usr/bin/env bash
# cached-op.sh - wraps 'op read' with a TTL cache, or reads from a plaintext file
# Supports multiple API keys; each OP path gets its own cache namespace.
# Usage:
#   cached-op.sh <op-path>  # 1Password mode
# Examples:
#   cached-op.sh "op://Private/china-ai-api-key/deepseek-api-key"
#   cached-op.sh "op://Private/china-ai-api-key/xiaomi-api-key"
# Cache files: <prefix>.key (fallback), <prefix>-<datehash> (daily TTL)

set -uo pipefail

OP_PATH="${1:?Usage: cached-op.sh <op-path>}"

CACHE_DIR="${HOME}/.cache/pi-op"
mkdir -p "${CACHE_DIR}"

# Derive a unique prefix from the OP path (last path component)
PREFIX="${OP_PATH##*/}"
FILE_PATH="${CACHE_DIR}/${PREFIX}.key"

printf -v DATE '%(%Y-%m-%d)T' -1
CACHE_KEY="${PREFIX}-$(echo -n "${DATE}" | shasum -a 256 | cut -d' ' -f1)"
CACHE_FILE="${CACHE_DIR}/${CACHE_KEY}"

_log() {
  printf '\x1B[2;32m[LOG] [%(%Y-%m-%d %H:%M:%S)T]: [%s] %s\x1B[0m\n' -1 "${PREFIX}" "$*"
}

_die() {
  printf '\x1B[2;31m[ERROR] [%(%Y-%m-%d %H:%M:%S)T]: [%s] %s\x1B[0m\n' -1 "${PREFIX}" "$*" >&2
  exit 1
}

_cleanup_old_cache() {
  local file
  # Only clean up stale cache files matching our prefix
  for file in "${CACHE_DIR}/${PREFIX}-"*; do
    [[ "${file}" == "${CACHE_FILE}" ]] && continue
    [[ -f "${file}" ]] || continue
    rm -f "${file}"
  done
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
  elif value=$(op read "${OP_PATH}" 2>/dev/null); then
    :
  else
    _die "Plaintext file '${FILE_PATH}' not found and no cached value available"
  fi

  printf '%s' "${value}" >"${CACHE_FILE}"
  _cleanup_old_cache
  _load_cache_file
}

main "$@"
