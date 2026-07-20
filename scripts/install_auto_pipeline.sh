#!/bin/bash

set -euo pipefail

LABEL="com.leondx.salesforce-knowledge-sync"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_PATH="$(cd "${SCRIPT_DIR}/.." && pwd)"
EXAMPLE_PLIST="${REPO_PATH}/automation/${LABEL}.plist.example"
LAUNCH_AGENTS_DIR="${HOME}/Library/LaunchAgents"
INSTALLED_PLIST="${LAUNCH_AGENTS_DIR}/${LABEL}.plist"
LOG_DIR="${HOME}/Library/Logs/LeonDX-Auto-Pipeline"
TEMPLATE_REPO_PATH="/Users/atsuo/Documents/LeonDX-Salesforce-Knowledge"
TEMPLATE_HOME="/Users/atsuo"

escape_sed_replacement() {
  printf '%s' "$1" | sed 's/[&|\\]/\\&/g'
}

if [[ ! -f "${EXAMPLE_PLIST}" ]]; then
  printf 'Example plist not found: %s\n' "${EXAMPLE_PLIST}" >&2
  exit 66
fi

mkdir -p "${LAUNCH_AGENTS_DIR}" "${LOG_DIR}"
REPO_REPLACEMENT="$(escape_sed_replacement "${REPO_PATH}")"
HOME_REPLACEMENT="$(escape_sed_replacement "${HOME}")"
sed \
  -e "s|${TEMPLATE_REPO_PATH}|${REPO_REPLACEMENT}|g" \
  -e "s|${TEMPLATE_HOME}|${HOME_REPLACEMENT}|g" \
  "${EXAMPLE_PLIST}" > "${INSTALLED_PLIST}"

plutil -lint "${INSTALLED_PLIST}"
launchctl unload "${INSTALLED_PLIST}" >/dev/null 2>&1 || true
launchctl load -w "${INSTALLED_PLIST}"

printf 'Installed and loaded %s\n' "${LABEL}"
printf 'Verify: launchctl list | grep %s\n' "${LABEL}"
printf 'Status: %s/scripts/status_auto_pipeline.sh\n' "${REPO_PATH}"
printf 'Dry-run: %s/scripts/leondx_auto_pipeline.sh --dry-run\n' "${REPO_PATH}"
