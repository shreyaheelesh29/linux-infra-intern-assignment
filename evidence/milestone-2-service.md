# Milestone 2: Service and systemd

Capture from the local Ubuntu VM:

```bash
systemctl status infra-demo --no-pager
curl -i http://localhost:8080/health
journalctl -u infra-demo -n 30 --no-pager
```

Expected evidence:

- `infra-demo` enabled and active
- HTTP response includes `{"status":"healthy"}`
- journal logs show service startup and requests
