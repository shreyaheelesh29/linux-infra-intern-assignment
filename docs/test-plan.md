# Test Plan

## Provisioning

- Run `sudo ./scripts/provision.sh` on Ubuntu Server 24.04.
- Confirm the script prints `Ubuntu 24.04 detected`.
- Confirm package installation completes successfully.
- Run the provisioner a second time to verify idempotency.

## Service

- Run `systemctl status infra-demo --no-pager`.
- Run `curl http://localhost:8080/health`.
- Expected response: `{"status": "healthy"}`.

## Logging

- Run `journalctl -u infra-demo -n 20 --no-pager`.
- Confirm service startup and request logs appear.

## Firewall

- Run `sudo ufw status verbose`.
- Confirm UFW is active.
- Confirm ports 22 and 8080 are allowed.

## SSH Hardening

- Run `sshd -T | grep -E 'permitrootlogin|maxauthtries'`.
- Confirm `permitrootlogin no`.
- Confirm `maxauthtries 3`.

## Maintenance Timer

- Run `systemctl list-timers infra-maintenance.timer --no-pager`.
- Confirm the timer is active and scheduled.
- Check `/var/log/infra-health.log` after the timer fires.

## Validation

- Run `sudo ./scripts/validate.sh`.
- Expected final result: `OVERALL: PASS`.

## Reboot

- Run `sudo reboot`.
- Reconnect to the VM.
- Run `sudo ./scripts/validate.sh` again.
- Expected final result: `OVERALL: PASS`.
