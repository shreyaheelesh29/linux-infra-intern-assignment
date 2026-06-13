#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/var/log/infra-health.log"

{
  echo "Health Check $(date --iso-8601=seconds)"
  curl -fsS http://localhost:8080/health
  echo
} >> "${LOG_FILE}"
