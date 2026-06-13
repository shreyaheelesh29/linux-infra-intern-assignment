#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: run this script with sudo"
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_USER="infrauser"
APP_DIR="/opt/infra-demo"
LOG_DIR="/var/log/infra-demo"
ENV_FILE="/etc/infra-demo.env"
SSHD_DROPIN="/etc/ssh/sshd_config.d/99-infra-hardening.conf"

source /etc/os-release
if [[ "${ID}" != "ubuntu" || "${VERSION_ID}" != "24.04" ]]; then
  echo "ERROR: Ubuntu 24.04 required. Detected ${PRETTY_NAME:-unknown}."
  exit 1
fi
echo "Ubuntu 24.04 detected"

echo "Updating package indexes and installed packages"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

echo "Installing required packages"
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  python3 \
  python3-pip \
  curl \
  git \
  ufw \
  openssh-server

echo "Creating operational user"
if id "${APP_USER}" >/dev/null 2>&1; then
  echo "User ${APP_USER} already exists"
else
  useradd -m -s /bin/bash "${APP_USER}"
fi
usermod -aG sudo "${APP_USER}"

echo "Creating project directories"
install -d -o root -g root -m 755 "${APP_DIR}"
install -d -o root -g root -m 755 "${LOG_DIR}"

echo "Installing application files"
install -o root -g root -m 755 "${REPO_ROOT}/app/server.py" "${APP_DIR}/server.py"
install -o root -g root -m 755 "${REPO_ROOT}/scripts/maintenance.sh" "${APP_DIR}/maintenance.sh"
install -o root -g root -m 640 "${REPO_ROOT}/config/infra-demo.env" "${ENV_FILE}"
install -o root -g root -m 644 "${REPO_ROOT}/systemd/infra-demo.service" "/etc/systemd/system/infra-demo.service"
install -o root -g root -m 644 "${REPO_ROOT}/systemd/infra-maintenance.service" "/etc/systemd/system/infra-maintenance.service"
install -o root -g root -m 644 "${REPO_ROOT}/systemd/infra-maintenance.timer" "/etc/systemd/system/infra-maintenance.timer"

echo "Applying SSH hardening"
install -d -o root -g root -m 755 /etc/ssh/sshd_config.d
cat > "${SSHD_DROPIN}" <<'EOF'
PermitRootLogin no
MaxAuthTries 3
EOF
chmod 644 "${SSHD_DROPIN}"
sshd -t
systemctl restart ssh || systemctl restart sshd

echo "Configuring firewall"
ufw allow 22/tcp
ufw allow 8080/tcp
ufw --force enable

echo "Enabling systemd units"
systemctl daemon-reload
systemctl enable infra-demo.service
systemctl restart infra-demo.service
systemctl enable infra-maintenance.timer
systemctl restart infra-maintenance.timer

echo "Provisioning complete"
systemctl --no-pager --full status infra-demo.service || true
