# Linux Server Provisioning and Hardening Lab

This repository automates the setup of a deployment-ready Ubuntu Server 24.04 VM.

## Architecture

```text
Fresh Ubuntu VM
    -> scripts/provision.sh
    -> packages installed
    -> infrauser created
    -> Python health service installed
    -> systemd service enabled
    -> firewall and SSH hardening applied
    -> maintenance timer enabled
    -> scripts/validate.sh verifies the result
```

The demo application is a small Python HTTP server listening on port `8080`.
It exposes:

```text
GET /health -> {"status":"healthy"}
```

## Requirements

- Ubuntu Server 24.04 LTS
- 4 GB RAM
- 2 CPU cores
- 25 GB disk
- Internet access during provisioning
- A user with sudo privileges

## Repository Layout

```text
app/                  Python demo service source
config/               Environment file copied to /etc
docs/                 Hardening checklist, test plan, reprovisioning notes
evidence/             Place screenshots and command output evidence here
scripts/              Provisioning, validation, and maintenance scripts
systemd/              systemd service and timer units
```

## Installation

Inside the Ubuntu VM:

```bash
sudo apt update
sudo apt install -y git
git clone <your-repository-url>
cd linux-infra-intern-assignment
```

If you copied the repository manually instead of cloning it, enter the copied folder.

## Provisioning

Run:

```bash
chmod +x scripts/*.sh
sudo ./scripts/provision.sh
```

The provisioner is idempotent. It can be run multiple times and will reuse existing
users, directories, service files, firewall rules, and hardening settings.

## Validation

Run:

```bash
sudo ./scripts/validate.sh
```

The script checks:

- Ubuntu version
- installed packages
- operational user
- service active and enabled state
- health endpoint
- listening port
- UFW firewall
- SSH hardening
- environment file permissions
- maintenance timer
- recent service logs

The final line should be:

```text
OVERALL: PASS
```

## Reboot Testing

Run validation before reboot:

```bash
sudo ./scripts/validate.sh
```

Reboot:

```bash
sudo reboot
```

After reconnecting:

```bash
cd linux-infra-intern-assignment
sudo ./scripts/validate.sh
```

The service and timer should still be enabled and validation should still pass.

## Troubleshooting

Check service status:

```bash
sudo systemctl status infra-demo --no-pager
```

Check logs:

```bash
sudo journalctl -u infra-demo -n 50 --no-pager
```

Check the health endpoint:

```bash
curl http://localhost:8080/health
```

Check the timer:

```bash
systemctl list-timers infra-maintenance.timer --no-pager
```

## AI Assistance Notes

AI assistance was used to draft the automation scripts, systemd units, validation
checks, and documentation. The implementation should still be tested manually in
the target Ubuntu Server 24.04 VM and evidence screenshots should be captured from
that VM.
