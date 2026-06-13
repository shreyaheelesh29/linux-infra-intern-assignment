# Troubleshooting

## Service Does Not Start

Check the service status:

```bash
sudo systemctl status infra-demo --no-pager
```

Check recent logs:

```bash
sudo journalctl -u infra-demo -n 50 --no-pager
```

Reload systemd after changing unit files:

```bash
sudo systemctl daemon-reload
sudo systemctl restart infra-demo
```

## Health Check Fails

Confirm the service is listening:

```bash
ss -tulpn | grep 8080
```

Test the endpoint:

```bash
curl -v http://localhost:8080/health
```

Expected response:

```json
{"status":"healthy"}
```

## Firewall Blocks Access

Check UFW:

```bash
sudo ufw status verbose
```

Allow required ports:

```bash
sudo ufw allow 22/tcp
sudo ufw allow 8080/tcp
sudo ufw --force enable
```

## SSH Restart Fails

Validate SSH configuration before restarting:

```bash
sudo sshd -t
```

Check the hardening drop-in:

```bash
cat /etc/ssh/sshd_config.d/99-infra-hardening.conf
```

## Timer Does Not Run

Check timer state:

```bash
systemctl list-timers infra-maintenance.timer --no-pager
systemctl status infra-maintenance.timer --no-pager
```

Run the maintenance service manually:

```bash
sudo systemctl start infra-maintenance.service
cat /var/log/infra-health.log
```

## Validation Fails After Reboot

Run:

```bash
sudo ./scripts/validate.sh
sudo systemctl status infra-demo infra-maintenance.timer --no-pager
```

If the service is disabled, rerun:

```bash
sudo ./scripts/provision.sh
```
