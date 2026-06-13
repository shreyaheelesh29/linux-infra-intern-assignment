# Milestone 3: Hardening and Automation

Capture from the local Ubuntu VM:

```bash
sudo ufw status verbose
sshd -T | grep -E 'permitrootlogin|maxauthtries'
stat /etc/infra-demo.env
stat /var/log/infra-demo
systemctl list-timers infra-maintenance.timer --no-pager
sudo ./scripts/provision.sh
```

Expected evidence:

- UFW active with only the expected assignment ports allowed
- root SSH login disabled
- SSH authentication retries limited
- environment file permissions restricted
- maintenance timer active
- second provisioning run completes without duplicate-user or duplicate-config errors
