#!/usr/bin/env bash
set -u

PASS_COUNT=0
FAIL_COUNT=0

pass() {
  echo "PASS: $1"
  PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
  echo "FAIL: $1"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

check() {
  local description="$1"
  shift
  if "$@" >/tmp/infra-validate-check.out 2>&1; then
    pass "${description}"
  else
    fail "${description}"
    sed 's/^/  /' /tmp/infra-validate-check.out
  fi
}

echo "== OS =="
if [[ -r /etc/os-release ]]; then
  . /etc/os-release
  echo "${PRETTY_NAME:-unknown}"
  [[ "${ID:-}" == "ubuntu" && "${VERSION_ID:-}" == "24.04" ]] && pass "Ubuntu 24.04 detected" || fail "Ubuntu 24.04 detected"
else
  fail "/etc/os-release readable"
fi

echo
echo "== Packages =="
for package in python3 python3-pip curl git ufw openssh-server; do
  check "package installed: ${package}" dpkg -s "${package}"
done

echo
echo "== User =="
check "infrauser exists" id infrauser
if id -nG infrauser 2>/dev/null | tr ' ' '\n' | grep -qx sudo; then
  pass "infrauser is in sudo group"
else
  fail "infrauser is in sudo group"
fi

echo
echo "== Service =="
check "infra-demo service is active" systemctl is-active --quiet infra-demo.service
check "infra-demo service is enabled" systemctl is-enabled --quiet infra-demo.service

echo
echo "== Health Endpoint =="
HEALTH_RESPONSE="$(curl -fsS http://localhost:8080/health 2>/tmp/infra-health.err)"
echo "${HEALTH_RESPONSE}"
if [[ "${HEALTH_RESPONSE}" == '{"status": "healthy"}' || "${HEALTH_RESPONSE}" == '{"status":"healthy"}' ]]; then
  pass "health endpoint returns healthy JSON"
else
  fail "health endpoint returns healthy JSON"
  sed 's/^/  /' /tmp/infra-health.err
fi

echo
echo "== Ports =="
if ss -tulpn | grep -q ':8080 '; then
  pass "port 8080 is listening"
else
  fail "port 8080 is listening"
fi
ss -tulpn | grep -E '(:22|:8080)' || true

echo
echo "== Firewall =="
if ufw status | grep -q "Status: active"; then
  pass "UFW is active"
else
  fail "UFW is active"
fi
ufw status verbose
ufw status | grep -Eq '^22/tcp|^22 ' && pass "SSH allowed through UFW" || fail "SSH allowed through UFW"
ufw status | grep -Eq '^8080/tcp|^8080 ' && pass "8080 allowed through UFW" || fail "8080 allowed through UFW"

echo
echo "== SSH Hardening =="
SSHD_EFFECTIVE="$(sshd -T 2>/tmp/infra-sshd.err)"
if echo "${SSHD_EFFECTIVE}" | grep -qx "permitrootlogin no"; then
  pass "root SSH login disabled"
else
  fail "root SSH login disabled"
fi
if echo "${SSHD_EFFECTIVE}" | grep -qx "maxauthtries 3"; then
  pass "SSH MaxAuthTries set to 3"
else
  fail "SSH MaxAuthTries set to 3"
fi

echo
echo "== Permissions =="
if [[ -f /etc/infra-demo.env ]]; then
  stat /etc/infra-demo.env
  OWNER_GROUP="$(stat -c '%U:%G' /etc/infra-demo.env)"
  MODE="$(stat -c '%a' /etc/infra-demo.env)"
  [[ "${OWNER_GROUP}" == "root:root" ]] && pass "/etc/infra-demo.env owned by root:root" || fail "/etc/infra-demo.env owned by root:root"
  [[ "${MODE}" == "640" ]] && pass "/etc/infra-demo.env mode is 640" || fail "/etc/infra-demo.env mode is 640"
else
  fail "/etc/infra-demo.env exists"
fi

echo
echo "== Maintenance Timer =="
check "infra-maintenance timer is enabled" systemctl is-enabled --quiet infra-maintenance.timer
check "infra-maintenance timer is active" systemctl is-active --quiet infra-maintenance.timer
systemctl list-timers infra-maintenance.timer --no-pager || true

echo
echo "== Recent Logs =="
journalctl -u infra-demo.service -n 20 --no-pager || true

echo
echo "== Summary =="
echo "Passed: ${PASS_COUNT}"
echo "Failed: ${FAIL_COUNT}"

if [[ "${FAIL_COUNT}" -eq 0 ]]; then
  echo "OVERALL: PASS"
  exit 0
fi

echo "OVERALL: FAIL"
exit 1
