# cached-op.bats — Test suite for home-manager/config/pi/cached-op.sh
#
# Usage:  bats tests/cached-op.bats
#
# Dependencies: bats, mktemp, shasum (or sha256sum)

setup() {
  export TEST_HOME
  TEST_HOME="$(mktemp -d /tmp/cached-op-test.XXXXXX)"
  export HOME="${TEST_HOME}"

  export CACHE_DIR="${HOME}/.cache/pi-op"
  export SCRIPT="${BATS_TEST_DIRNAME}/../home-manager/config/pi/cached-op.sh"
  export MOCK_DIR="${BATS_TEST_DIRNAME}/mocks"

  PATH="${MOCK_DIR}:${PATH}"
}

teardown() {
  rm -rf "${TEST_HOME}"
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Derive prefix from OP path (mirrors ${OP_PATH##*/} in the script)
_prefix() {
  local path="${1:-op://private/test-key/credential}"
  echo "${path##*/}"
}

# Build today's cache key: <prefix>-<sha256-of-date>
_today_cache_key() {
  local prefix="${1:-credential}"
  local today
  printf -v today '%(%Y-%m-%d)T' -1
  echo "${prefix}-$(echo -n "${today}" | shasum -a 256 | cut -d' ' -f1)"
}

# Seed a cached value for a given OP path (default: credential / secret-from-cache)
prime_cache() {
  local op_path="${1:-op://private/test-key/credential}"
  local value="${2:-secret-from-cache}"
  local prefix
  prefix="$(_prefix "${op_path}")"
  mkdir -p "${CACHE_DIR}"
  local cache_key
  cache_key="$(echo -n "$(date +%Y-%m-%d)" | shasum -a 256 | cut -d' ' -f1)"
  echo -n "${value}" >"${CACHE_DIR}/${prefix}-${cache_key}"
}

# Seed a plaintext fallback file for a given OP path (default: credential / secret-from-plaintext)
prime_plaintext() {
  local op_path="${1:-op://private/test-key/credential}"
  local value="${2:-secret-from-plaintext}"
  local prefix
  prefix="$(_prefix "${op_path}")"
  mkdir -p "${CACHE_DIR}"
  echo -n "${value}" >"${CACHE_DIR}/${prefix}.key"
}

clear_cache() {
  rm -rf "${CACHE_DIR}"
}

# ===========================================================================
# Core behaviour
# ===========================================================================

@test "cache hit — returns cached value without calling op" {
  prime_cache "op://private/test-key/credential" "my-cached-secret"

  run bash "${SCRIPT}" "op://private/test-key/credential"

  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "my-cached-secret" ]]
}

@test "no cache, plaintext file exists — reads from file and creates cache" {
  clear_cache
  prime_plaintext "op://private/test-key/credential" "secret-from-file"

  run bash "${SCRIPT}" "op://private/test-key/credential"

  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "secret-from-file" ]]

  # Verify cache was created with prefixed key
  local cache_key
  cache_key="$(_today_cache_key "credential")"
  [[ -f "${CACHE_DIR}/${cache_key}" ]]
  [[ "$(cat "${CACHE_DIR}/${cache_key}")" == "secret-from-file" ]]
}

@test "no cache, no plaintext, op succeeds — reads from op and creates cache" {
  clear_cache

  run bash "${SCRIPT}" "op://private/test-key/credential"

  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "mock-op-secret" ]]

  # Verify cache was created with prefixed key
  local cache_key
  cache_key="$(_today_cache_key "credential")"
  [[ -f "${CACHE_DIR}/${cache_key}" ]]
  [[ "$(cat "${CACHE_DIR}/${cache_key}")" == "mock-op-secret" ]]
}

@test "all sources exhausted — exits with error" {
  clear_cache
  export OP_FAIL=1

  run bash "${SCRIPT}" "op://private/test-key/credential"

  [[ "${status}" -ne 0 ]]
  [[ "${output}" =~ "not found" ]] || [[ "${output}" =~ "No cached value" ]]
}

@test "cache expiry — old cache ignored, falls through to plaintext" {
  clear_cache
  mkdir -p "${CACHE_DIR}"

  local prefix
  prefix="$(_prefix "op://private/test-key/credential")"

  # Seed a cache file with yesterday's date hash
  local yesterday
  yesterday="$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d 'yesterday' +%Y-%m-%d)"
  local old_key="${prefix}-$(echo -n "${yesterday}" | shasum -a 256 | cut -d' ' -f1)"
  echo -n "stale-secret" >"${CACHE_DIR}/${old_key}"

  # Plaintext file with today's value
  prime_plaintext "op://private/test-key/credential" "fresh-secret"

  run bash "${SCRIPT}" "op://private/test-key/credential"

  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "fresh-secret" ]]
}

@test "required argument — fails with usage message when no op-path given" {
  clear_cache

  run bash "${SCRIPT}"

  [[ "${status}" -ne 0 ]]
  [[ "${output}" =~ "Usage" ]]
}

@test "cleanup — same-prefix old caches removed, .key and other-prefix files survive" {
  clear_cache
  mkdir -p "${CACHE_DIR}"

  # ---- Same prefix (credential) ----
  local prefix
  prefix="$(_prefix "op://private/test-key/credential")"

  # Two stale caches for prefix "credential" → should be cleaned
  local day1 day2
  day1="$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d 'yesterday' +%Y-%m-%d)"
  day2="$(date -v-3d +%Y-%m-%d 2>/dev/null || date -d '3 days ago' +%Y-%m-%d)"
  local stale1="${prefix}-$(echo -n "${day1}" | shasum -a 256 | cut -d' ' -f1)"
  local stale2="${prefix}-$(echo -n "${day2}" | shasum -a 256 | cut -d' ' -f1)"
  echo -n "stale-1" >"${CACHE_DIR}/${stale1}"
  echo -n "stale-2" >"${CACHE_DIR}/${stale2}"

  # Plaintext fallback for "credential" → must survive
  echo -n "credential-secret" >"${CACHE_DIR}/${prefix}.key"

  # ---- Different prefix (deepseek-api-key) — should NOT be touched ----
  local other_prefix="deepseek-api-key"
  local other_day
  other_day="$(date -v-2d +%Y-%m-%d 2>/dev/null || date -d '2 days ago' +%Y-%m-%d)"
  local other_cache="${other_prefix}-$(echo -n "${other_day}" | shasum -a 256 | cut -d' ' -f1)"
  echo -n "other-cache" >"${CACHE_DIR}/${other_cache}"

  local file_count_before
  file_count_before="$(find "${CACHE_DIR}" -type f | wc -l | tr -d ' ')"
  (( file_count_before == 4 ))  # stale1, stale2, credential.key, other_cache

  run bash "${SCRIPT}" "op://private/test-key/credential"

  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "credential-secret" ]]

  # After cleanup: today's cache + credential.key + other_cache should remain
  local today_key
  today_key="$(_today_cache_key "${prefix}")"
  [[ -f "${CACHE_DIR}/${today_key}" ]]
  [[ -f "${CACHE_DIR}/${prefix}.key" ]]
  [[ -f "${CACHE_DIR}/${other_cache}" ]]

  local file_count_after
  file_count_after="$(find "${CACHE_DIR}" -type f | wc -l | tr -d ' ')"
  (( file_count_after == 3 ))
}

@test "plaintext file with trailing newline — preserved as-is" {
  clear_cache
  mkdir -p "${CACHE_DIR}"
  local prefix
  prefix="$(_prefix "op://private/test-key/credential")"
  printf "secret-with-newline\n" >"${CACHE_DIR}/${prefix}.key"

  run bash "${SCRIPT}" "op://private/test-key/credential"

  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "secret-with-newline" ]]
}

# ===========================================================================
# Multi-provider isolation
# ===========================================================================

@test "multi-provider — deepseek and xiaomi caches coexist independently" {
  clear_cache

  local ds_path="op://Private/china-ai-api-key/deepseek-api-key"
  local mi_path="op://Private/china-ai-api-key/xiaomi-api-key"

  # Prime both caches with different values
  prime_cache "${ds_path}" "ds-secret-456"
  prime_cache "${mi_path}" "mi-secret-789"

  # DeepSeek hit
  run bash "${SCRIPT}" "${ds_path}"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "ds-secret-456" ]]

  # MiMo hit (independent)
  run bash "${SCRIPT}" "${mi_path}"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "mi-secret-789" ]]

  # Both files exist
  local ds_prefix mi_prefix
  ds_prefix="$(_prefix "${ds_path}")"
  mi_prefix="$(_prefix "${mi_path}")"
  local ds_key mi_key
  ds_key="$(_today_cache_key "${ds_prefix}")"
  mi_key="$(_today_cache_key "${mi_prefix}")"
  [[ -f "${CACHE_DIR}/${ds_key}" ]]
  [[ -f "${CACHE_DIR}/${mi_key}" ]]
}

@test "multi-provider — plaintext fallback per provider" {
  clear_cache

  local ds_path="op://Private/china-ai-api-key/deepseek-api-key"
  local mi_path="op://Private/china-ai-api-key/xiaomi-api-key"

  prime_plaintext "${ds_path}" "ds-plain"
  prime_plaintext "${mi_path}" "mi-plain"

  run bash "${SCRIPT}" "${ds_path}"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "ds-plain" ]]

  run bash "${SCRIPT}" "${mi_path}"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "mi-plain" ]]
}

@test "multi-provider — switching providers does not clobber other's cache" {
  clear_cache

  local ds_path="op://Private/china-ai-api-key/deepseek-api-key"
  local mi_path="op://Private/china-ai-api-key/xiaomi-api-key"

  # Step 1: fetch deepseek via op → creates ds cache
  run bash "${SCRIPT}" "${ds_path}"
  [[ "${status}" -eq 0 ]]
  local ds_prefix
  ds_prefix="$(_prefix "${ds_path}")"
  local ds_key
  ds_key="$(_today_cache_key "${ds_prefix}")"
  [[ -f "${CACHE_DIR}/${ds_key}" ]]
  [[ "$(cat "${CACHE_DIR}/${ds_key}")" == "mock-op-secret" ]]

  # Step 2: fetch xiaomi via plaintext → creates mi cache, ds cache still intact
  prime_plaintext "${mi_path}" "mi-secret"
  run bash "${SCRIPT}" "${mi_path}"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "mi-secret" ]]

  # DeepSeek cache must still exist with original value
  [[ -f "${CACHE_DIR}/${ds_key}" ]]
  [[ "$(cat "${CACHE_DIR}/${ds_key}")" == "mock-op-secret" ]]
}

@test "multi-provider — cleanup of one prefix leaves other intact" {
  clear_cache
  mkdir -p "${CACHE_DIR}"

  local ds_path="op://Private/china-ai-api-key/deepseek-api-key"
  local mi_path="op://Private/china-ai-api-key/xiaomi-api-key"
  local ds_prefix mi_prefix
  ds_prefix="$(_prefix "${ds_path}")"
  mi_prefix="$(_prefix "${mi_path}")"

  # Stale caches for both prefixes
  local yesterday
  yesterday="$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d 'yesterday' +%Y-%m-%d)"
  local ds_old="${ds_prefix}-$(echo -n "${yesterday}" | shasum -a 256 | cut -d' ' -f1)"
  local mi_old="${mi_prefix}-$(echo -n "${yesterday}" | shasum -a 256 | cut -d' ' -f1)"
  echo -n "ds-stale" >"${CACHE_DIR}/${ds_old}"
  echo -n "mi-stale" >"${CACHE_DIR}/${mi_old}"

  # Plaintext fallbacks
  echo -n "ds-plain" >"${CACHE_DIR}/${ds_prefix}.key"
  echo -n "mi-plain" >"${CACHE_DIR}/${mi_prefix}.key"

  # Fetch deepseek → triggers cleanup of ds-* stale caches only
  run bash "${SCRIPT}" "${ds_path}"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "ds-plain" ]]

  # MiMo stale cache + plaintext must still exist
  [[ -f "${CACHE_DIR}/${mi_old}" ]]
  [[ -f "${CACHE_DIR}/${mi_prefix}.key" ]]

  # DeepSeek stale cache must be gone
  [[ ! -f "${CACHE_DIR}/${ds_old}" ]]
}
