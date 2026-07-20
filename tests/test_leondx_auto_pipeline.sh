#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PIPELINE_SCRIPT="${PROJECT_ROOT}/scripts/leondx_auto_pipeline.sh"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/leondx-auto-pipeline-tests.XXXXXX")"
PASSED=0
FAILED=0

cleanup() {
  rm -rf "${TEST_ROOT}"
}
trap cleanup EXIT

pass() {
  PASSED=$((PASSED + 1))
  printf 'ok - %s\n' "$1"
}

fail() {
  FAILED=$((FAILED + 1))
  printf 'not ok - %s: %s\n' "$1" "$2" >&2
  if [[ -f "${OUTPUT_FILE:-}" ]]; then
    sed 's/^/  | /' "${OUTPUT_FILE}" >&2
  fi
}

assert_contains() {
  local file=$1
  local expected=$2
  grep -Fq -- "${expected}" "${file}"
}

new_fixture() {
  local name=$1
  CASE_DIR="${TEST_ROOT}/${name}"
  ORIGIN_DIR="${CASE_DIR}/origin.git"
  SEED_DIR="${CASE_DIR}/seed"
  REPO_DIR="${CASE_DIR}/repo"
  PUBLISHER_DIR="${CASE_DIR}/publisher"
  LOG_DIR="${CASE_DIR}/logs"
  MOCK_BIN_DIR="${CASE_DIR}/mock-bin"
  MOCK_CALL_LOG="${CASE_DIR}/mock-calls.log"
  OUTPUT_FILE="${CASE_DIR}/output.log"

  mkdir -p "${CASE_DIR}" "${LOG_DIR}" "${MOCK_BIN_DIR}"
  git init --bare --initial-branch=main "${ORIGIN_DIR}" >/dev/null
  git clone "${ORIGIN_DIR}" "${SEED_DIR}" >/dev/null 2>&1
  git -C "${SEED_DIR}" config user.name "Pipeline Test"
  git -C "${SEED_DIR}" config user.email "pipeline-test@example.invalid"
  printf '# Test repository\n' > "${SEED_DIR}/README.md"
  git -C "${SEED_DIR}" add README.md
  git -C "${SEED_DIR}" commit -m "Initial commit" >/dev/null
  git -C "${SEED_DIR}" push origin main >/dev/null 2>&1
  git clone "${ORIGIN_DIR}" "${REPO_DIR}" >/dev/null 2>&1
  git clone "${ORIGIN_DIR}" "${PUBLISHER_DIR}" >/dev/null 2>&1
  git -C "${PUBLISHER_DIR}" config user.name "Pipeline Test"
  git -C "${PUBLISHER_DIR}" config user.email "pipeline-test@example.invalid"

  apply_patch_mock
}

apply_patch_mock() {
  local mock_path="${MOCK_BIN_DIR}/leondx-ai-sync"
  touch "${MOCK_CALL_LOG}"
  sed \
    -e "s|__MOCK_CALL_LOG__|${MOCK_CALL_LOG}|g" \
    "${PROJECT_ROOT}/tests/fixtures/leondx-ai-sync.mock" > "${mock_path}"
  chmod +x "${mock_path}"
}

publish_file() {
  local relative_path=$1
  local content=$2
  mkdir -p "${PUBLISHER_DIR}/$(dirname "${relative_path}")"
  printf '%s\n' "${content}" > "${PUBLISHER_DIR}/${relative_path}"
  git -C "${PUBLISHER_DIR}" add "${relative_path}"
  git -C "${PUBLISHER_DIR}" commit -m "Update ${relative_path}" >/dev/null
  git -C "${PUBLISHER_DIR}" push origin main >/dev/null 2>&1
}

run_pipeline() {
  local sync_exit=${1:-0}
  shift || true
  PATH="${MOCK_BIN_DIR}:${PATH}" \
    REPO_PATH="${REPO_DIR}" \
    LOG_DIR="${LOG_DIR}" \
    LOCK_DIR="${LOG_DIR}/pipeline.lock" \
    SYNC_COMMAND="leondx-ai-sync sync" \
    STATUS_COMMAND="leondx-ai-sync status" \
    MOCK_SYNC_EXIT="${sync_exit}" \
    bash "${PIPELINE_SCRIPT}" "$@" > "${OUTPUT_FILE}" 2>&1
}

test_no_remote_changes() {
  local name="no remote changes"
  new_fixture "no-remote-changes"
  if run_pipeline && assert_contains "${OUTPUT_FILE}" "Update exists: no" && [[ ! -s "${MOCK_CALL_LOG}" ]]; then
    pass "${name}"
  else
    fail "${name}" "expected a successful no-op"
  fi
}

test_remote_update_exists() {
  local name="remote update exists"
  new_fixture "remote-update"
  publish_file "docs/updated.md" "# Updated"
  if run_pipeline && assert_contains "${OUTPUT_FILE}" "Update exists: yes" &&
    grep -Fq -- "sync --file docs/updated.md" "${MOCK_CALL_LOG}" &&
    grep -Fq -- "status" "${MOCK_CALL_LOG}"; then
    pass "${name}"
  else
    fail "${name}" "expected pull, incremental sync, and status"
  fi
}

test_dirty_working_tree() {
  local name="dirty working tree"
  new_fixture "dirty-tree"
  printf 'dirty\n' > "${REPO_DIR}/dirty.txt"
  if ! run_pipeline && assert_contains "${OUTPUT_FILE}" "Working tree is not clean"; then
    pass "${name}"
  else
    fail "${name}" "expected a safe failure"
  fi
}

test_lock_already_held() {
  local name="lock already held"
  new_fixture "held-lock"
  mkdir "${LOG_DIR}/pipeline.lock"
  if ! run_pipeline && assert_contains "${OUTPUT_FILE}" "already holds the lock"; then
    pass "${name}"
  else
    fail "${name}" "expected lock contention failure"
  fi
}

test_excluded_files_only() {
  local name="excluded files only"
  new_fixture "excluded-only"
  publish_file "assets/ignored.md" "# Excluded"
  if run_pipeline && assert_contains "${OUTPUT_FILE}" "assets/ignored.md" &&
    assert_contains "${OUTPUT_FILE}" "No eligible Markdown files changed" &&
    ! grep -Fq -- "sync" "${MOCK_CALL_LOG}" && grep -Fq -- "status" "${MOCK_CALL_LOG}"; then
    pass "${name}"
  else
    fail "${name}" "expected sync skip and status check"
  fi
}

test_ai_sync_failure() {
  local name="AI Sync failure"
  new_fixture "sync-failure"
  publish_file "docs/failure.md" "# Failure"
  if ! run_pipeline 42 && assert_contains "${OUTPUT_FILE}" "Pipeline failed with exit code 42" &&
    ! grep -Fq -- "status" "${MOCK_CALL_LOG}"; then
    pass "${name}"
  else
    fail "${name}" "expected non-zero exit and no status call"
  fi
}

test_dry_run_mode() {
  local name="dry-run mode"
  new_fixture "dry-run"
  publish_file "docs/dry-run.md" "# Dry run"
  local before_commit
  before_commit="$(git -C "${REPO_DIR}" rev-parse HEAD)"
  if run_pipeline 0 --dry-run &&
    assert_contains "${OUTPUT_FILE}" "Update exists: yes" &&
    assert_contains "${OUTPUT_FILE}" "docs/dry-run.md" &&
    assert_contains "${OUTPUT_FILE}" "Would run: git pull --ff-only origin main" &&
    [[ "$(git -C "${REPO_DIR}" rev-parse HEAD)" == "${before_commit}" ]] &&
    [[ ! -s "${MOCK_CALL_LOG}" ]]; then
    pass "${name}"
  else
    fail "${name}" "expected report-only behavior"
  fi
}

test_no_remote_changes
test_remote_update_exists
test_dirty_working_tree
test_lock_already_held
test_excluded_files_only
test_ai_sync_failure
test_dry_run_mode

printf '\n%d passed, %d failed\n' "${PASSED}" "${FAILED}"
[[ ${FAILED} -eq 0 ]]
