#!/bin/bash

set -euo pipefail

LABEL="com.leondx.salesforce-knowledge-sync"
INSTALLED_PLIST="${HOME}/Library/LaunchAgents/${LABEL}.plist"

if [[ -f "${INSTALLED_PLIST}" ]]; then
  launchctl unload "${INSTALLED_PLIST}" >/dev/null 2>&1 || true
  rm "${INSTALLED_PLIST}"
  printf 'Unloaded %s and removed %s\n' "${LABEL}" "${INSTALLED_PLIST}"
else
  printf 'LaunchAgent is not installed: %s\n' "${INSTALLED_PLIST}"
fi

printf 'Logs and repository files were preserved.\n'
