# Final Evidence: Reboot Validation

Capture from the local Ubuntu VM before reboot:

```bash
sudo ./scripts/validate.sh
```

Then reboot:

```bash
sudo reboot
```

After reconnecting to the VM:

```bash
cd linux-infra-intern-assignment
uptime
sudo ./scripts/validate.sh
```

Expected evidence:

- validation passes before reboot
- uptime shows the machine restarted
- validation passes again after reboot
