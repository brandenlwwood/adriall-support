# Adriall Remote Support — RustDesk Installers

Pre-configured RustDesk installers that connect to Adriall's self-hosted relay server. Clients run one script and get an ID + password to share — no manual configuration needed.

## For Clients

### Windows
Send them `Install-Adriall-Support.bat` — they double-click it and it handles everything:
1. Downloads RustDesk
2. Installs silently
3. Configures your server
4. Generates a random password
5. Displays the ID + password (also copies to clipboard)

**Alternative:** If hosting the `.ps1` on GitHub, the `.bat` will download and run it automatically.

### Linux
```bash
curl -fsSL https://raw.githubusercontent.com/brandenlwwood/adriall-support/main/install-rustdesk.sh | sudo bash
```

Or send them the `.sh` file:
```bash
chmod +x install-rustdesk.sh
sudo ./install-rustdesk.sh
```

## For You (Technician)
1. Send the appropriate installer to the client
2. They run it and read back the ID + password
3. You connect via RustDesk using those credentials

## Server Details
- **Relay:** minewood.redirectme.net
- **Key:** `6PgU7uQGTcmBvA86IlJ1QNuDve4ILtFq0iu4pbiQ3hY=`
- **Hosted on:** Unraid (10.10.1.6)

## Hosting Options
- **GitHub repo** — easiest, `.bat` can pull `.ps1` directly
- **Your website** — host the scripts behind a short URL
- **Email attachment** — send `.bat` (Windows) or `.sh` (Linux) directly

## Updating
When a new RustDesk version drops, update the `VERSION` variable at the top of each script.
