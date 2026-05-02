# Troubleshooting Guide

## Error: Docker Timeout Connecting to ghcr.io

The error message:

```
Error response from daemon: Get "https://ghcr.io/v2/": net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
```

means Docker could not connect to the GitHub Container Registry (GHCR). This is a network or authentication issue, not a problem with your compose file or image tags.

**Common causes:**
- Internet connectivity issues or firewall blocking access to ghcr.io.
- GHCR is temporarily down or rate-limited.
- Docker is not logged in to GHCR, or your token/credentials have expired.

**How to fix:**
1. Check your internet connection and retry.
2. Make sure you are logged in to GHCR:
   ```
   echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
   ```
   Replace `$CR_PAT` with your GitHub token and `USERNAME` with your GitHub username.
3. If you are behind a proxy or firewall, ensure it allows outbound HTTPS to ghcr.io.
4. Check https://www.githubstatus.com/ for GHCR outages.


If the problem still persists...

**Possible causes and next steps:**

1. **Network/Firewall/Proxy Issues:**
   - Are you behind a corporate VPN, proxy, or firewall? These often block or throttle Docker registry traffic.
   - Try accessing https://ghcr.io/ in your browser. If it fails, your network is blocking it.
   - If on VPN, try disconnecting or switching networks.

2. **GHCR Outage:**
   - Check https://www.githubstatus.com/ for any ongoing issues with GitHub Container Registry.

3. **Docker Daemon Issues:**
   - Restart Docker:  
     ```
     sudo systemctl restart docker
     ```
   - Then try again.

4. **DNS Issues:**
   - Try flushing your DNS cache or switching to a public DNS (like 8.8.8.8).

5. **Test with curl:**
   - Run:  
     ```
     curl -v https://ghcr.io/v2/
     ```
   - If this hangs or fails, it confirms a network issue.

**Summary:**  
This is a network-level problem, not a Docker Compose or workflow bug. Please check your network, proxy, and firewall settings, and try the above diagnostics.

## Error: "container ... is not running" after detached startup

If you started the platform with:

```bash
docker run -d --name medtech-platform \
   -v /var/run/docker.sock:/var/run/docker.sock \
   ghcr.io/chaithubk/medtech-platform:latest up -d
```

the `medtech-platform` wrapper container may exit after it starts the service stack. This is expected behavior in detached mode.

Use these commands instead of `docker exec medtech-platform ...`:

```bash
# Runtime service logs
docker logs -f vitals-publisher
docker logs -f edge-analytics
docker logs -f clinician-ui

# Stack status using the wrapper image CLI
docker run --rm -it \
   -v /var/run/docker.sock:/var/run/docker.sock \
   ghcr.io/chaithubk/medtech-platform:latest ps
```

## Fresh restart (published image)

```bash
# Stop running stack
docker run --rm -it \
   -v /var/run/docker.sock:/var/run/docker.sock \
   ghcr.io/chaithubk/medtech-platform:latest down

# Remove old wrapper container if present
docker rm -f medtech-platform 2>/dev/null || true

# Pull latest wrapper image and start again
docker pull ghcr.io/chaithubk/medtech-platform:latest
docker run -d --name medtech-platform \
   -v /var/run/docker.sock:/var/run/docker.sock \
   ghcr.io/chaithubk/medtech-platform:latest up -d
```
