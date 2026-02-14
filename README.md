# Remote Support — RustDesk Installers

Generic, pre-configured RustDesk installers. Server config is passed as parameters — no secrets in the repo.

## Scripts

### Windows (`install-rustdesk.ps1`)
```powershell
.\install-rustdesk.ps1 -Server "your.server.com" -Key "your_public_key"
```

Parameters:
| Param | Required | Description |
|-------|----------|-------------|
| `-Server` | Yes | RustDesk server hostname |
| `-Key` | Yes | Server public key |
| `-Name` | No | Company name shown during install (default: "Remote Support") |
| `-Version` | No | RustDesk version (default: 1.4.1) |

### Linux (`install-rustdesk.sh`)
```bash
curl -fsSL https://raw.githubusercontent.com/<you>/adriall-support/main/install-rustdesk.sh \
  | sudo bash -s -- --server your.server.com --key "your_public_key"
```

Parameters: `--server`, `--key`, `--name`, `--version`

## Usage

### Option A: .bat wrapper (Windows)
Create a `.bat` file that downloads the generic `.ps1` and passes your config:
```bat
powershell.exe -ExecutionPolicy Bypass -Command "& { $s = (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/<you>/adriall-support/main/install-rustdesk.ps1'); $sb = [scriptblock]::Create($s); & $sb -Server 'your.server.com' -Key 'your_key' -Name 'Your Company' }"
```
Email this `.bat` to clients. Your config lives in the `.bat`, not the repo.

### Option B: One-liner (Linux)
```bash
curl -fsSL https://raw.githubusercontent.com/<you>/adriall-support/main/install-rustdesk.sh \
  | sudo bash -s -- --server your.server.com --key "your_key" --name "Your Company"
```

## What it does
1. Downloads RustDesk from GitHub releases
2. Installs silently
3. Configures your self-hosted server
4. Generates a random password
5. Displays ID + password for the client to share

No manual configuration. No confusion.
