#!/bin/bash

set -euo pipefail

DEFAULT_REPO_PATH="/Users/atsuo/Documents/LeonDX-Salesforce-Knowledge"
DEFAULT_LOG_DIR="${HOME}/Library/Logs/LeonDX-Auto-Pipeline"
DEFAULT_SYNC_COMMAND="leondx-ai-sync sync"
DEFAULT_STATUS_COMMAND="leondx-ai-sync status"
DEFAULT_EXCLUDED_PATHS=".github/:assets/:drafts/:config/:automation/:scripts/:LICENSE:CODEOWNERS:CONTRIBUTING.md"

CONFIG_REPO_PATH="${REPO_PATH:-${DEFAULT_REPO_PATH}}"
CONFIG_FILE="${LEONDX_AUTO_PIPELINE_CONFIG:-${CONFIG_REPO_PATH}/config/auto-pipeline.env}"
if [[ -f "${CONFIG_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${CONFIG_FILE}"
fi

REPO_PATH="${REPO_PATH:-${DEFAULT_REPO_PATH}}"
LOG_DIR="${LOG_DIR:-${DEFAULT_LOG_DIR}}"
SYNC_COMMAND="${SYNC_COMMAND:-${DEFAULT_SYNC_COMMAND}}"
STATUS_COMMAND="${STATUS_COMMAND:-${DEFAULT_STATUS_COMMAND}}"
EXCLUDED_PATHS="${EXCLUDED_PATHS:-${DEFAULT_EXCLUDED_PATHS}}"
LOCK_DIR="${LOCK_DIR:-${LOG_DIR}/pipeline.lock}"
DRY_RUN=false
LOCK_ACQUIRED=false
CHANGED_FILE_LIST=""

usage() {
  printf 'Usage: %s [--dry-run]\n' "$0"
}

if [[ $# -gt 1 ]]; then
  usage >&2
  exit 64
fi

if [[ $# -eq 1 ]]; then
  case "$1" in
    --dry-run)
      DRY_RUN=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 64
      ;;
  esac
fi

mkdir -p "${LOG_DIR}"
TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"
LOG_FILE="${LOG_DIR}/pipeline-${TIMESTAMP}-$$.log"
touch "${LOG_FILE}"
chmod 600 "${LOG_FILE}"

redact_stream() {
  sed -E \
    -e 's/([Aa][Pp][Ii][_-]?[Kk][Ee][Yy][=:][[:space:]]*)[^[:space:]]+/\1[REDACTED]/g' \
    -e 's/sk-[A-Za-z0-9_-]{16,}/[REDACTED]/g'
}

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S%z')" "$*" |
    redact_stream | tee -a "${LOG_FILE}"
}

emit() {
  tee -a "${LOG_FILE}"
}

run_logged() {
  "$@" 2>&1 | redact_stream | tee -a "${LOG_FILE}"
  return "${PIPESTATUS[0]}"
}

cleanup() {
  if [[ "${LOCK_ACQUIRED}" == true ]]; then
    rmdir "${LOCK_DIR}" 2>/dev/null || true
  fi
  if [[ -n "${CHANGED_FILE_LIST}" && -f "${CHANGED_FILE_LIST}" ]]; then
    rm "${CHANGED_FILE_LIST}"
  fi
}

finish() {
  local exit_code=$?
  if [[ ${exit_code} -eq 0 ]]; then
    log "Pipeline completed successfully. Log: ${LOG_FILE}"
  else
    log "Pipeline failed with exit code ${exit_code}. Log: ${LOG_FILE}"
  fi
  cleanup
}

trap finish EXIT

if ! mkdir "${LOCK_DIR}" 2>/dev/null; then
  log "ERROR: Another pipeline process already holds the lock: ${LOCK_DIR}"
  exit 75
fi
LOCK_ACQUIRED=true

log "Starting LeonDX Auto Pipeline."
if [[ "${DRY_RUN}" == true ]]; then
  log "Mode: dry-run (no pull or synchronization will occur)."
else
  log "Mode: live."
fi

if [[ ! -d "${REPO_PATH}" ]]; then
  log "ERROR: Repository directory does not exist: ${REPO_PATH}"
  exit 66
fi
cd "${REPO_PATH}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  log "ERROR: REPO_PATH is not a Git working tree: ${REPO_PATH}"
  exit 65
fi

CURRENT_BRANCH="$(git branch --show-current)"
if [[ "${CURRENT_BRANCH}" != "main" ]]; then
  log "ERROR: The repository must be on main; current branch is ${CURRENT_BRANCH:-detached HEAD}."
  exit 65
fi

if [[ -n "$(git status --porcelain --untracked-files=normal)" ]]; then
  log "ERROR: Working tree is not clean. Commit, stash, or remove local changes first."
  run_logged git status --short
  exit 65
fi

if ! git show-ref --verify --quiet refs/heads/main; then
  log "ERROR: Local main branch does not exist."
  exit 65
fi

PREVIOUS_COMMIT="$(git rev-parse refs/heads/main)"
log "Command: git fetch origin main"
run_logged git fetch origin main

if ! git show-ref --verify --quiet refs/remotes/origin/main; then
  log "ERROR: origin/main was not created by git fetch."
  exit 69
fi

REMOTE_COMMIT="$(git rev-parse refs/remotes/origin/main)"
log "Local main:  ${PREVIOUS_COMMIT}"
log "Remote main: ${REMOTE_COMMIT}"

if [[ "${PREVIOUS_COMMIT}" == "${REMOTE_COMMIT}" ]]; then
  log "Update exists: no. Local main is already current."
  exit 0
fi

log "Update exists: yes."
if ! git merge-base --is-ancestor "${PREVIOUS_COMMIT}" "${REMOTE_COMMIT}"; then
  log "ERROR: Local main cannot be fast-forwarded to origin/main. Manual recovery is required."
  exit 65
fi

CHANGED_FILES=()
CHANGED_COUNT=0
CHANGED_FILE_LIST="$(mktemp "${TMPDIR:-/tmp}/leondx-changed-files.XXXXXX")"
git diff --name-only --diff-filter=ACMRT -z "${PREVIOUS_COMMIT}" "${REMOTE_COMMIT}" > "${CHANGED_FILE_LIST}"
while IFS= read -r -d '' changed_file; do
  CHANGED_FILES+=("${changed_file}")
  CHANGED_COUNT=$((CHANGED_COUNT + 1))
done < "${CHANGED_FILE_LIST}"

is_excluded() {
  local file=$1
  local excluded_path
  local excluded_paths=()
  [[ -z "${EXCLUDED_PATHS}" ]] && return 1
  IFS=':' read -r -a excluded_paths <<< "${EXCLUDED_PATHS}"
  for excluded_path in "${excluded_paths[@]}"; do
    [[ -z "${excluded_path}" ]] && continue
    if [[ "${excluded_path}" == */ ]]; then
      [[ "${file}" == "${excluded_path}"* ]] && return 0
    elif [[ "${file}" == "${excluded_path}" ]]; then
      return 0
    fi
  done
  return 1
}

EXCLUDED_FILES=()
SYNC_FILES=()
EXCLUDED_COUNT=0
SYNC_COUNT=0
if [[ ${CHANGED_COUNT} -gt 0 ]]; then
  for changed_file in "${CHANGED_FILES[@]}"; do
    if is_excluded "${changed_file}"; then
      EXCLUDED_FILES+=("${changed_file}")
      EXCLUDED_COUNT=$((EXCLUDED_COUNT + 1))
    elif [[ "${changed_file}" == *.md || "${changed_file}" == *.markdown ]]; then
      SYNC_FILES+=("${changed_file}")
      SYNC_COUNT=$((SYNC_COUNT + 1))
    fi
  done
fi

print_file_list() {
  local heading=$1
  local count=$2
  shift 2
  log "${heading} (${count}):"
  if [[ ${count} -eq 0 ]]; then
    printf '  (none)\n' | emit
  else
    printf '  %s\n' "$@" | emit
  fi
}

if [[ ${CHANGED_COUNT} -eq 0 ]]; then
  print_file_list "Changed files" 0
else
  print_file_list "Changed files" "${CHANGED_COUNT}" "${CHANGED_FILES[@]}"
fi
if [[ ${EXCLUDED_COUNT} -eq 0 ]]; then
  print_file_list "Excluded files" 0
else
  print_file_list "Excluded files" "${EXCLUDED_COUNT}" "${EXCLUDED_FILES[@]}"
fi
if [[ ${SYNC_COUNT} -eq 0 ]]; then
  print_file_list "Files eligible for synchronization" 0
else
  print_file_list "Files eligible for synchronization" "${SYNC_COUNT}" "${SYNC_FILES[@]}"
fi

if [[ -z "${SYNC_COMMAND}" || -z "${STATUS_COMMAND}" ]]; then
  log "ERROR: SYNC_COMMAND and STATUS_COMMAND must not be empty."
  exit 64
fi
read -r -a SYNC_ARGS <<< "${SYNC_COMMAND}"
read -r -a STATUS_ARGS <<< "${STATUS_COMMAND}"

if [[ "${DRY_RUN}" == true ]]; then
  log "Would run: git pull --ff-only origin main"
  if [[ ${SYNC_COUNT} -gt 0 ]]; then
    log "Would inspect incremental support: ${SYNC_COMMAND} --help"
    for sync_file in "${SYNC_FILES[@]}"; do
      log "Would run incremental sync when supported: ${SYNC_COMMAND} --file <eligible-file> (file: ${sync_file})"
    done
    log "Would otherwise run repository sync once: ${SYNC_COMMAND}"
  else
    log "Would skip AI Sync because no eligible Markdown files changed."
  fi
  log "Would run: ${STATUS_COMMAND}"
  exit 0
fi

log "Command: git pull --ff-only origin main"
run_logged git pull --ff-only origin main
NEW_COMMIT="$(git rev-parse HEAD)"
if [[ "${NEW_COMMIT}" != "${REMOTE_COMMIT}" ]]; then
  log "ERROR: HEAD does not match the fetched origin/main after pull."
  exit 70
fi

if [[ ${SYNC_COUNT} -gt 0 ]]; then
  if ! command -v "${SYNC_ARGS[0]}" >/dev/null 2>&1; then
    log "ERROR: AI Sync command is not installed: ${SYNC_ARGS[0]}"
    exit 69
  fi

  SYNC_HELP="$("${SYNC_ARGS[@]}" --help 2>&1 || true)"
  INCREMENTAL_OPTION=""
  if grep -Eq -- '(^|[[:space:]])--file([=[:space:],]|$)' <<< "${SYNC_HELP}"; then
    INCREMENTAL_OPTION="--file"
  elif grep -Eq -- '(^|[[:space:]])--path([=[:space:],]|$)' <<< "${SYNC_HELP}"; then
    INCREMENTAL_OPTION="--path"
  fi

  if [[ -n "${INCREMENTAL_OPTION}" ]]; then
    log "Incremental synchronization supported via ${INCREMENTAL_OPTION}."
    for sync_file in "${SYNC_FILES[@]}"; do
      log "Synchronizing eligible file: ${sync_file}"
      run_logged "${SYNC_ARGS[@]}" "${INCREMENTAL_OPTION}" "${sync_file}"
    done
  else
    log "Incremental synchronization is unavailable; running repository-level sync."
    run_logged "${SYNC_ARGS[@]}"
  fi
else
  log "No eligible Markdown files changed; skipping AI Sync."
fi

if ! command -v "${STATUS_ARGS[0]}" >/dev/null 2>&1; then
  log "ERROR: Status command is not installed: ${STATUS_ARGS[0]}"
  exit 69
fi
log "Command: ${STATUS_COMMAND}"
run_logged "${STATUS_ARGS[@]}"
log "Updated main from ${PREVIOUS_COMMIT} to ${NEW_COMMIT}."
