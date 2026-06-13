#!/usr/bin/env bash
set -euo pipefail

OUTPUT_DIR="${1:-${HOME}/Downloads/linux-infra-evidence}"
mkdir -p "${OUTPUT_DIR}"

capture_text() {
  local name="$1"
  shift
  {
    echo "$ $*"
    "$@"
  } > "${OUTPUT_DIR}/${name}.txt" 2>&1 || true
}

capture_text "01-ubuntu-version" bash -lc 'cat /etc/os-release'
capture_text "02-repo-structure" bash -lc 'find . -maxdepth 3 -type f | sort'
capture_text "03-service-status" systemctl status infra-demo.service --no-pager
capture_text "04-health-endpoint" curl -fsS http://localhost:8080/health
capture_text "05-service-logs" journalctl -u infra-demo.service -n 50 --no-pager
capture_text "06-firewall-status" ufw status verbose
capture_text "07-timer-status" systemctl list-timers infra-maintenance.timer --no-pager
capture_text "08-env-permissions" stat /etc/infra-demo.env
capture_text "09-validation" sudo ./scripts/validate.sh

if command -v gnome-screenshot >/dev/null 2>&1; then
  echo "gnome-screenshot is available. Capture terminal screenshots manually into ${OUTPUT_DIR}."
else
  echo "Saved text evidence to ${OUTPUT_DIR}."
  echo "If your Ubuntu VM has a desktop, install gnome-screenshot to capture PNG screenshots."
fi
