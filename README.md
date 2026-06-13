# Linux Server Provisioning and Hardening Lab

This repository automates the setup of a deployment-ready Ubuntu Server 24.04 VM
running locally in VirtualBox, VMware, Hyper-V, UTM, or a similar local
virtualization tool.

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
- Local VM only; do not use AWS, Azure, Google Cloud, DigitalOcean, Linode, Oracle Cloud, or another cloud VM
- 4 GB RAM
- 2 CPU cores
- 25 GB disk
- Internet access during provisioning
- A user with sudo privileges

## Assumptions

- The target VM is a fresh Ubuntu Server 24.04 LTS install.
- The provisioning script is run inside the VM, not on the personal host machine.
- The default hostname and timezone are left unchanged to avoid surprising VM-wide changes.
- To opt in to hostname or timezone changes, run:

```bash
sudo INFRA_HOSTNAME=infra-demo INFRA_TIMEZONE=UTC ./scripts/provision.sh
```

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
git clone https://github.com/shreyaheelesh29/linux-infra-intern-assignment.git
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
- hostname, timezone, uptime, and last boot context
- installed packages
- operational user
- service active and enabled state
- health endpoint
- listening port
- UFW firewall
- SSH hardening
- environment file permissions
- controlled log directory permissions
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

More troubleshooting steps are in `docs/troubleshooting.md`.

## Evidence

Capture evidence from inside the local Ubuntu VM. Recommended files are listed in
`evidence/README.md`, including:

- `milestone-1-setup`
- `milestone-2-service`
- `milestone-3-hardening`
- `final-reboot-validation`

You can collect text evidence with:

```bash
./scripts/capture-evidence.sh
```

Screenshots should show the VM terminal, not the personal host machine.

## Demo Video

Record a 1-3 minute demo from the local VM showing:

- repository structure
- `sudo ./scripts/provision.sh`
- `curl localhost:8080/health`
- `sudo ./scripts/validate.sh`
- reboot
- `sudo ./scripts/validate.sh` after reboot

Demo video link: add the final recording link here before submission.

## AI Assistance Notes

AI assistance was used to draft the automation scripts, systemd units, validation
checks, and documentation. The Python health endpoint was smoke-tested locally,
and the full provisioning flow should be manually verified inside the target
Ubuntu Server 24.04 VM. Evidence screenshots and the demo video should be
captured from that VM.
