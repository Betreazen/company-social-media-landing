# Quickstart: Server Deployment

Complete guide to deploy the Endorphina Social Media Landing Page on Ubuntu server.

---

## Prerequisites

| Requirement | Value |
|-------------|-------|
| OS | Ubuntu 22.04 / 24.04 LTS |
| RAM | 1 GB minimum |
| Disk | 10 GB minimum |
| Ports | 80, 443 open |

---

## Step 1: Install Docker on Ubuntu

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to docker group (logout required)
sudo usermod -aG docker $USER

# Verify installation
docker --version
docker compose version
```

> **Note:** Log out and log back in for group changes to take effect.

---

## Step 2: Configure Firewall

```bash
# Allow SSH (if using UFW)
sudo ufw allow 22/tcp

# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable

# Verify status
sudo ufw status
```

---

## Step 3: Clone Repository

```bash
# Clone to recommended directory
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git /opt/endorphina-links

# Navigate to project directory
cd /opt/endorphina-links
```

---

## Step 4: Initial Launch (HTTP Only)

```bash
# Build and start containers
docker compose up -d --build

# Verify containers are running
docker compose ps
```

Expected output:
```
NAME                  STATUS
endorphina-nginx      Up
endorphina-certbot    Up
```

Verify site is accessible at `http://YOUR_DOMAIN`

---

## Step 5: Issue SSL Certificate

```bash
# Request certificate from Let's Encrypt
docker compose run --rm certbot certonly \
  --webroot \
  -w /var/www/certbot \
  -d YOUR_DOMAIN \
  --email your-email@example.com \
  --agree-tos \
  --no-eff-email
```

Replace:
- `YOUR_DOMAIN` — your actual domain name
- `your-email@example.com` — your email for expiry notifications

---

## Step 6: Enable HTTPS

### 6.1 Update SSL Configuration

```bash
# Edit the SSL config file
nano nginx/default-ssl.conf
```

Replace all occurrences of `YOUR_DOMAIN` with your actual domain.

### 6.2 Switch to SSL Config

```bash
# Edit docker-compose.yml
nano docker-compose.yml
```

Change this line:
```yaml
- ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
```

To:
```yaml
- ./nginx/default-ssl.conf:/etc/nginx/conf.d/default.conf:ro
```

### 6.3 Restart Containers

```bash
# Restart with new configuration
docker compose down
docker compose up -d
```

Verify HTTPS at `https://YOUR_DOMAIN`

---

## Step 7: Setup Auto-Renewal Cron

```bash
# Open crontab editor
crontab -e

# Add this line to reload Nginx daily at 3 AM
0 3 * * * cd /opt/endorphina-links && docker compose exec -T nginx nginx -s reload >/dev/null 2>&1
```

---

## Maintenance Commands

### View Logs

```bash
# Nginx logs
docker compose logs nginx

# Certbot logs
docker compose logs certbot

# Follow logs in real-time
docker compose logs -f
```

### Update Site Content

```bash
# After editing links/styles/components
cd /opt/endorphina-links
docker compose up -d --build
```

### Manual Certificate Renewal

```bash
# Force renewal check
docker compose run --rm certbot renew

# Reload Nginx to apply new certificates
docker compose exec nginx nginx -s reload
```

### Stop All Containers

```bash
docker compose down
```

### Restart All Containers

```bash
docker compose restart
```

---

## Troubleshooting

### Check Container Status

```bash
docker compose ps
```

### Check Nginx Configuration

```bash
docker compose exec nginx nginx -t
```

### Check Certificate Status

```bash
docker compose run --rm certbot certificates
```

### View Detailed Logs

```bash
# Last 100 lines of nginx logs
docker compose logs --tail=100 nginx
```

---

## DNS Configuration Reminder

Before deployment, ensure DNS A record is configured:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ or subdomain | Server IP | 300 |

DNS propagation can take up to 48 hours (usually minutes).

---

## Security Checklist

After successful HTTPS deployment:

- [ ] Verify HTTPS works with padlock icon
- [ ] Uncomment HSTS header in `nginx/default-ssl.conf`
- [ ] Restart containers after enabling HSTS
- [ ] Configure SSH key authentication
- [ ] Disable password SSH login
- [ ] Install fail2ban for SSH protection

---

## Quick Reference

| Action | Command |
|--------|---------|
| Start | `docker compose up -d` |
| Stop | `docker compose down` |
| Rebuild | `docker compose up -d --build` |
| Logs | `docker compose logs -f` |
| Status | `docker compose ps` |
| Restart | `docker compose restart` |
