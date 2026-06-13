# Local VM Reprovisioning

Use this process to prove that provisioning is repeatable.

1. Install Ubuntu Server 24.04 in VirtualBox.
2. Install Git and clone or copy this repository.
3. Take a VirtualBox snapshot named `fresh-ubuntu-before-provision`.
4. Run:

   ```bash
   chmod +x scripts/*.sh
   sudo ./scripts/provision.sh
   sudo ./scripts/validate.sh
   ```

5. Save screenshots or text evidence.
6. Restore the `fresh-ubuntu-before-provision` snapshot.
7. Run the same provisioning and validation commands again.
8. Confirm validation ends with `OVERALL: PASS` both times.

To prove idempotency without restoring the snapshot, run:

```bash
sudo ./scripts/provision.sh
sudo ./scripts/provision.sh
sudo ./scripts/validate.sh
```

The second provisioning run should complete without user creation, firewall, or
systemd errors.
