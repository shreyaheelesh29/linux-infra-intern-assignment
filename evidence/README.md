# Evidence Guide

Save screenshots or command output for each milestone in this folder.

Recommended evidence:

- `01-ubuntu-version.png` or `.txt`: `cat /etc/os-release`
- `02-repo-structure.png` or `.txt`: repository tree
- `03-provision-first-run.png` or `.txt`: first `sudo ./scripts/provision.sh`
- `04-service-status.png` or `.txt`: `systemctl status infra-demo`
- `05-health-endpoint.png` or `.txt`: `curl localhost:8080/health`
- `06-service-logs.png` or `.txt`: `journalctl -u infra-demo`
- `07-firewall-status.png` or `.txt`: `sudo ufw status verbose`
- `08-timer-status.png` or `.txt`: `systemctl list-timers`
- `09-permissions.png` or `.txt`: `stat /etc/infra-demo.env`
- `10-validate-before-reboot.png` or `.txt`: validation before reboot
- `11-validate-after-reboot.png` or `.txt`: validation after reboot

You can also run:

```bash
./scripts/capture-evidence.sh
```

By default it saves text evidence to:

```text
~/Downloads/linux-infra-evidence
```
