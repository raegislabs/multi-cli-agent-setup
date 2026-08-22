---
description: Check health of a deployed service
---

Check the health status of the service at: $ARGUMENTS

Steps:
1. Run `curl -s -o /dev/null -w "%{http_code}" <url>/health` to check the HTTP status
2. Run `curl -s <url>/health | head -c 500` to see the response body
3. If the health endpoint returns non-200, check:
   - Is the service running? (`systemctl status <service>`)
   - Are there recent errors in logs? (`journalctl -u <service> --since "10 min ago"`)
   - Is the port bound? (`ss -tlnp | grep <port>`)
4. Report the status clearly: healthy, degraded, or down
