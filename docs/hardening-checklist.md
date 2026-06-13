# Hardening Checklist

## Applied Controls

| Control | Why it was applied | Verification |
| --- | --- | --- |
| Package indexes updated and packages upgraded | Reduces exposure to known package vulnerabilities before deploying the service. | `sudo apt update`, `sudo apt upgrade -y`, `scripts/validate.sh` package checks |
| UFW enabled | Provides a simple host firewall baseline. | `sudo ufw status verbose` |
| SSH allowed on port 22 | Keeps remote administration available after enabling UFW. | `sudo ufw status` |
| Application port 8080 allowed | Allows access to the demo health endpoint. | `sudo ufw status`, `curl localhost:8080/health` |
| Root SSH login disabled | Reduces brute-force risk against the root account. | `sshd -T | grep permitrootlogin` |
| `MaxAuthTries 3` | Limits repeated SSH authentication attempts. | `sshd -T | grep maxauthtries` |
| `/etc/infra-demo.env` owned by `root:root` | Prevents unprivileged users from changing service runtime config. | `stat /etc/infra-demo.env` |
| `/etc/infra-demo.env` mode `640` | Restricts environment file reads and writes. | `stat -c "%U %G %a %n" /etc/infra-demo.env` |
| Service managed by systemd | Ensures service supervision, boot start, and journal logging. | `systemctl status infra-demo` |
| Maintenance timer enabled | Provides recurring health snapshots for operational visibility. | `systemctl list-timers infra-maintenance.timer` |
| Controlled log directory | Keeps application log files under `/var/log/infra-demo`. | `stat /var/log/infra-demo`, `tail /var/log/infra-demo/infra-demo.log` |

## Intentionally Skipped For Safety

| Control | Reason skipped |
| --- | --- |
| Changing the default SSH port | This can lock users out during a take-home assignment and is not required for a safe local VM baseline. |
| Disabling password authentication globally | This can break access if SSH keys are not prepared first. The safer baseline here disables root login and limits retries. |
| Removing or disabling running services automatically | The script cannot know which VM services are required by the evaluator's local environment. Services should be reviewed manually. |
| Changing hostname/timezone by default | These are environment-specific. The script supports `INFRA_HOSTNAME` and `INFRA_TIMEZONE` variables when the user wants to opt in. |
| Aggressive kernel/sysctl hardening | Out of scope for this mini lab and can cause unexpected networking or service behavior. |

## Manual Review Notes

After provisioning, review any unused services with:

```bash
systemctl --type=service --state=running
```

Disable only services that are clearly unnecessary for the VM's purpose.
