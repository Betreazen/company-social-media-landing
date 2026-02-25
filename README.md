# Endorphina — Social Media Link Hub

A self-hosted, single-page link-in-bio landing page for Endorphina — a fully controlled Linktree alternative. It serves as a centralized brand hub linking to official social media channels with a premium dark aesthetic.

## Tech Stack

| Technology | Purpose |
|---|---|
| [Astro](https://astro.build/) | Static site generation (frontend) |
| Custom CSS | Styling, glow/neon effects |
| JSON config | Social media link storage |
| Nginx | Serving static files, HTTPS termination |
| Certbot | Let's Encrypt SSL certificate management |
| Docker Compose | Container orchestration and deployment |

## Project Structure

```
├── docker-compose.yml          # Container orchestration
├── Dockerfile                  # Multi-stage build (Astro → Nginx)
├── nginx/
│   ├── default.conf            # HTTP-only config (initial launch)
│   └── default-ssl.conf        # HTTPS config (after SSL setup)
├── certbot/www/                # ACME challenge webroot
├── letsencrypt/                # SSL certificates (auto-managed)
├── public/
│   ├── assets/
│   │   ├── logo.svg            # Endorphina logo (user-provided)
│   │   ├── icons/              # Social media SVG icons
│   │   └── fonts/              # Benzin-Bold.woff2 (user-provided)
│   └── favicon.svg
├── src/
│   ├── components/             # Astro components
│   ├── data/links.json         # ✏️ Editable link configuration
│   ├── layouts/
│   ├── pages/
│   └── styles/                 # CSS (variables, global, components)
├── astro.config.mjs
├── package.json
└── tsconfig.json
```

## Local Development

### Prerequisites

- [Node.js](https://nodejs.org/) 20+ installed

### Install and Run

```bash
# Install dependencies
npm install

# Start development server
npm run dev
```

The dev server starts at `http://localhost:4321`.

### Production Build (local)

```bash
npm run build
```

Output is generated in the `dist/` directory.

## Changing Social Media Links

Edit the file **`src/data/links.json`**:

```json
[
  {
    "id": "linkedin",
    "title": "LinkedIn",
    "url": "https://www.linkedin.com/company/endorphina",
    "icon": "/assets/icons/linkedin.svg"
  }
]
```

| Field | Description |
|---|---|
| `id` | Unique identifier (used as `data-social` attribute) |
| `title` | Display name shown on the card |
| `url` | Full destination URL (include UTM params if needed) |
| `icon` | Path to SVG icon in `public/assets/icons/` |

**Rules:**
- Array order = card display order on the page
- To add a new social channel, append a new JSON object and add the corresponding SVG icon to `public/assets/icons/`

## Replacing Logo / Icons / Font

| Asset | Location | Notes |
|---|---|---|
| Company logo | `public/assets/logo.svg` | SVG recommended; PNG also works |
| Social icons | `public/assets/icons/` | One SVG per platform, named by `id` |
| Custom font | `public/assets/fonts/Benzin-Bold.woff2` | WOFF2 format; falls back to system sans-serif |
| Favicon | `public/favicon.svg` | SVG favicon; replace with `.ico` if preferred |

## Deployment (Docker Compose)

### Server Requirements

- **OS:** Ubuntu 22.04 or 24.04
- **RAM:** 1 GB minimum
- **Disk:** 10 GB minimum
- **Open ports:** 80 (HTTP) and 443 (HTTPS)
- **Software:** Docker and Docker Compose installed
- **DNS:** Domain/subdomain with an A record pointing to the server IP

### Step 1: Clone and Configure

```bash
git clone <your-repo-url> /opt/endorphina-links
cd /opt/endorphina-links
```

### Step 2: Initial Launch (HTTP Only)

The default configuration serves the site over HTTP on port 80. This is required for the initial Certbot domain validation.

```bash
docker compose up -d --build
```

Verify the site is accessible at `http://YOUR_DOMAIN`.

### Step 3: Issue SSL Certificate

With the Nginx container running on port 80, request a certificate:

```bash
docker compose run --rm certbot certonly \
  --webroot \
  -w /var/www/certbot \
  -d YOUR_DOMAIN \
  --email your-email@example.com \
  --agree-tos \
  --no-eff-email
```

Replace `YOUR_DOMAIN` and `your-email@example.com` with your actual values.

### Step 4: Switch to HTTPS Configuration

1. Edit `nginx/default-ssl.conf` — replace all occurrences of `YOUR_DOMAIN` with your actual domain.

2. Update the Nginx volume mount in `docker-compose.yml` to use the SSL config:

```yaml
volumes:
  - ./nginx/default-ssl.conf:/etc/nginx/conf.d/default.conf:ro
```

3. Restart the stack:

```bash
docker compose down
docker compose up -d
```

The site is now served over HTTPS. HTTP requests on port 80 are automatically redirected to HTTPS.

### Step 5: Verify HTTPS

Open `https://YOUR_DOMAIN` in a browser and confirm the padlock icon is displayed.

After confirming HTTPS works correctly, you can optionally uncomment the HSTS header in `nginx/default-ssl.conf` for enhanced security.

## Certificate Renewal

### Automatic Renewal

The Certbot container runs an auto-renewal check every 12 hours. When a certificate is within 30 days of expiry, Certbot automatically renews it.

### Reload Nginx After Renewal

After Certbot renews the certificate, Nginx must reload to pick up the new files. Run this command on the host (or set up a cron job):

```bash
docker compose exec nginx nginx -s reload
```

### Recommended: Host Cron Job

Add a cron job on the host to reload Nginx daily at 3 AM (after the renewal window):

```bash
crontab -e
```

Add this line:

```
0 3 * * * cd /opt/endorphina-links && docker compose exec -T nginx nginx -s reload >/dev/null 2>&1
```

### Manual Renewal (if needed)

```bash
docker compose run --rm certbot renew
docker compose exec nginx nginx -s reload
```

## Domain and DNS

Before deploying with HTTPS, ensure:

1. You own or control a domain/subdomain
2. An **A record** points the domain to your VPS public IP address
3. DNS propagation is complete (can take up to 48 hours, usually minutes)
4. Ports **80** and **443** are open in your server's firewall

Example DNS configuration:

```
Type: A
Name: links (or @ for root domain)
Value: 123.45.67.89 (your VPS IP)
TTL: 300
```

## Updating the Site

After making changes to links, styles, or components:

```bash
# Rebuild and restart
docker compose up -d --build
```

The multi-stage Docker build will rebuild the Astro site and produce a fresh Nginx image.

## License

Private project — Endorphina © 2026. All rights reserved.
