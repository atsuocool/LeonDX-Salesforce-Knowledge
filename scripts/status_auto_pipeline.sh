#!/bin/bash

set -euo pipefail

LABEL="com.leondx.salesforce-knowledge-sync"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_REPO_PATH="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONFIG_REPO_PATH="${REPO_PATH:-${DEFAULT_REPO_PATH}}"
CONFIG_FILE="${LEONDX_AUTO_PIPELINE_CONFIG:-${CONFIG_REPO_PATH}/config/auto-pipeline.env}"
if [[ -f "${CONFIG_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${CONFIG_FILE}"
fi
REPO_PATH="${REPO_PATH:-${DEFAULT_REPO_PATH}}"
LOG_DIR="${LOG_DIR:-${HOME}/Library/Logs/LeonDX-Auto-Pipeline}"

printf 'LaunchAgent status (%s):\n' "${LABEL}"
launchctl list "${LABEL}" 2>&1 || printf '  Not loaded.\n'

printf '\nLatest pipeline log entries:\n'
LATEST_LOG="$(find "${LOG_DIR}" -maxdepth 1 -type f -name 'pipeline-*.log' -print 2>/dev/null | sort | tail -n 1 || true)"
if [[ -n "${LATEST_LOG}" ]]; then
  printf '  %s\n' "${LATEST_LOG}"
  tail -n 30 "${LATEST_LOG}"
else
  printf '  No pipeline logs found in %s\n' "${LOG_DIR}"
fi

if ! git -C "${REPO_PATH}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  printf '\nRepository unavailable: %s\n' "${REPO_PATH}" >&2
  exit 65
fi

printf '\nCurrent Git branch:\n'
git -C "${REPO_PATH}" branch --show-current
printf '\nWorking-tree status:\n'
if [[ -z "$(git -C "${REPO_PATH}" status --short)" ]]; then
  printf '  clean\n'
else
  git -C "${REPO_PATH}" status --short
fi

printf '\nCommit IDs:\n'
printf '  local HEAD:  %s\n' "$(git -C "${REPO_PATH}" rev-parse HEAD)"
REMOTE_COMMIT="$(git -C "${REPO_PATH}" ls-remote origin refs/heads/main 2>/dev/null | awk 'NR == 1 { print $1 }' || true)"
if [[ -n "${REMOTE_COMMIT}" ]]; then
  printf '  remote main: %s\n' "${REMOTE_COMMIT}"
else
  printf '  remote main: unavailable (offline or remote error)\n'
fi
