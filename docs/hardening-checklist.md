# Hardening Checklist

- [x] Ubuntu package indexes updated
- [x] Installed packages upgraded during provisioning
- [x] UFW firewall enabled
- [x] SSH allowed on port 22
- [x] Application port 8080 allowed
- [x] Root SSH login disabled
- [x] SSH MaxAuthTries set to 3
- [x] Application environment file owned by root
- [x] Application environment file permissions set to 640
- [x] Application managed by systemd with automatic restart
- [x] Maintenance task automated with systemd timer
- [x] Validation script checks service, network, firewall, permissions, logs, and timer

## Manual Review Notes

After provisioning, review any unused services with:

```bash
systemctl --type=service --state=running
```

Disable only services that are clearly unnecessary for the VM's purpose.
