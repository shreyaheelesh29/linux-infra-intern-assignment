# Evidence Guide

Save screenshots or command output for each milestone in this folder. The `.md`
files in this directory list the exact commands to run and the evidence to
capture from the local Ubuntu VM.

Recommended evidence:

- `milestone-1-setup.png` or `.txt`: OS version, repo structure, first provisioning run
- `milestone-2-service.png` or `.txt`: systemd status, health endpoint, service logs
- `milestone-3-hardening.png` or `.txt`: firewall, SSH hardening, timer, permissions, idempotency
- `final-reboot-validation.png` or `.txt`: validation before and after reboot

You can also run:

```bash
./scripts/capture-evidence.sh
```

By default it saves text evidence to:

```text
~/Downloads/linux-infra-evidence
```
