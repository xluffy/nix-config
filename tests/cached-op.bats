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

prime_cache() {
  local value="${1:-secret-from-cache}"
  mkdir -p "${CACHE_DIR}"
  local today
  today="$(date +%Y-%m-%d)"
  local cache_key
  cache_key="$(echo -n "${today}" | shasum -a 256 | cut -d' ' -f1)"
  echo -n "${value}" >"${CACHE_DIR}/${cache_key}"
}

prime_plaintext() {
  local value="${1:-secret-from-plaintext}"
  mkdir -p "${CACHE_DIR}"
  echo -n "${value}" >"${CACHE_DIR}/deepseek.key"
}

clear_cache() {
  rm -rf "${CACHE_DIR}"
}

# ===========================================================================
# Tests
# ===========================================================================

@test "cache hit — returns cached value without calling op" {
  prime_cache "my-cached-secret"

  run bash "${SCRIPT}" "op://private/test-key/credential"

  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "my-cached-secret" ]]
}

@test "no cache, plaintext file exists — reads from file and creates cache" {
  clear_cache
  prime_plaintext "secret-from-file"

  run bash "${SCRIPT}" "op://private/test-key/credential"

  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "secret-from-file" ]]

  # Verify cache was created
  local today
  today="$(date +%Y-%m-%d)"
  local cache_key
  cache_key="$(echo -n "${today}" | shasum -a 256 | cut -d' ' -f1)"
  [[ -f "${CACHE_DIR}/${cache_key}" ]]
  [[ "$(cat "${CACHE_DIR}/${cache_key}")" == "secret-from-file" ]]
}

@test "no cache, no plaintext, op succeeds — reads from op and creates cache" {
  clear_cache

  # The mock 'op' in MOCK_DIR echoes a fixed secret
  run bash "${SCRIPT}" "op://private/test-key/credential"

  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "mock-op-secret" ]]

  # Verify cache was created
  local today
  today="$(date +%Y-%m-%d)"
  local cache_key
  cache_key="$(echo -n "${today}" | shasum -a 256 | cut -d' ' -f1)"
  [[ -f "${CACHE_DIR}/${cache_key}" ]]
  [[ "$(cat "${CACHE_DIR}/${cache_key}")" == "mock-op-secret" ]]
}

@test "all sources exhausted — exits with error" {
  clear_cache

  # Remove the mock op so the command truly fails
  # By setting OP_FAIL=1, mock op returns non-zero
  export OP_FAIL=1

  run bash "${SCRIPT}" "op://private/test-key/credential"

  [[ "${status}" -ne 0 ]]
  [[ "${output}" =~ "not found" ]] || [[ "${output}" =~ "No cached value" ]]
}

@test "cache expiry — old cache ignored, falls through to plaintext" {
  clear_cache
  mkdir -p "${CACHE_DIR}"

  # Seed a cache file with a *yesterday's* date hash
  local yesterday
  yesterday="$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d 'yesterday' +%Y-%m-%d)"
  local old_key
  old_key="$(echo -n "${yesterday}" | shasum -a 256 | cut -d' ' -f1)"
  echo -n "stale-secret" >"${CACHE_DIR}/${old_key}"

  # Plaintext file has today's value
  prime_plaintext "fresh-secret"

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

@test "cleanup — old cache files removed, plaintext fallback preserved" {
  clear_cache
  mkdir -p "${CACHE_DIR}"

  # Seed two old cache files from different previous days
  local day1 day2 old_key1 old_key2
  day1="$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d 'yesterday' +%Y-%m-%d)"
  day2="$(date -v-3d +%Y-%m-%d 2>/dev/null || date -d '3 days ago' +%Y-%m-%d)"
  old_key1="$(echo -n "${day1}" | shasum -a 256 | cut -d' ' -f1)"
  old_key2="$(echo -n "${day2}" | shasum -a 256 | cut -d' ' -f1)"
  printf '%s' "stale-secret-1" >"${CACHE_DIR}/${old_key1}"
  printf '%s' "stale-secret-2" >"${CACHE_DIR}/${old_key2}"

  # Plaintext fallback should be preserved after cleanup
  printf '%s' "persistent-secret" >"${CACHE_DIR}/deepseek.key"

  local file_count_before
  file_count_before="$(find "${CACHE_DIR}" -type f | wc -l | tr -d ' ')"
  (( file_count_before == 3 ))

  run bash "${SCRIPT}" "op://private/test-key/credential"

  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "persistent-secret" ]]

  # Only today's cache file + deepseek.key should remain
  local today cache_key
  printf -v today '%(%Y-%m-%d)T' -1
  cache_key="$(echo -n "${today}" | shasum -a 256 | cut -d' ' -f1)"
  [[ -f "${CACHE_DIR}/${cache_key}" ]]
  [[ -f "${CACHE_DIR}/deepseek.key" ]]

  local file_count_after
  file_count_after="$(find "${CACHE_DIR}" -type f | wc -l | tr -d ' ')"
  (( file_count_after == 2 ))
}

@test "plaintext file with leading/trailing whitespace" {
  clear_cache
  mkdir -p "${CACHE_DIR}"
  # Intentional trailing newline — common in file-based secrets
  printf "secret-with-newline\n" >"${CACHE_DIR}/deepseek.key"

  run bash "${SCRIPT}" "op://private/test-key/credential"

  [[ "${status}" -eq 0 ]]
  # cat preserves the newline, so the value includes it
  [[ "${output}" == "secret-with-newline" ]]
}
