# ============================================================
# Adriall Remote Support — RustDesk Installer for Windows
# Run as Administrator: Right-click → Run with PowerShell
# ============================================================

$ErrorActionPreference = "Stop"
$Version = "1.4.1"
$DownloadUrl = "https://github.com/rustdesk/rustdesk/releases/download/$Version/rustdesk-$Version-x86_64.exe"
$InstallerPath = "$env:TEMP\rustdesk-installer.exe"
$ConfigDir = "$env:APPDATA\RustDesk\config"

# Server configuration
$ServerConfig = @"
rendezvous_server = 'minewood.redirectme.net:21116'
nat_type = 1
serial = 0
unlock_pin = ''

[options]
custom-rendezvous-server = 'minewood.redirectme.net'
relay-server = 'minewood.redirectme.net'
api-server = 'http://minewood.redirectme.net:21116'
key = '6PgU7uQGTcmBvA86IlJ1QNuDve4ILtFq0iu4pbiQ3hY='
"@

# Generate a random 8-character password
$Password = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 8 | ForEach-Object { [char]$_ })

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Adriall Remote Support Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check for admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Restarting as Administrator..." -ForegroundColor Yellow
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Step 1: Download
Write-Host "[1/4] Downloading RustDesk v$Version..." -ForegroundColor Yellow
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($DownloadUrl, $InstallerPath)
    Write-Host "       Downloaded successfully." -ForegroundColor Green
} catch {
    Write-Host "       Download failed: $_" -ForegroundColor Red
    Write-Host "       Please check your internet connection and try again." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 2: Install silently
Write-Host "[2/4] Installing RustDesk..." -ForegroundColor Yellow
Start-Process -FilePath $InstallerPath -ArgumentList "--silent-install" -Wait
Start-Sleep -Seconds 5
Write-Host "       Installed successfully." -ForegroundColor Green

# Step 3: Stop the service and configure
Write-Host "[3/4] Configuring for Adriall remote support..." -ForegroundColor Yellow
Stop-Service -Name "RustDesk" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Write config to all possible locations
$configLocations = @(
    "$env:APPDATA\RustDesk\config",
    "$env:ProgramFiles\RustDesk",
    "C:\Windows\ServiceProfiles\LocalService\AppData\Roaming\RustDesk\config"
)

foreach ($dir in $configLocations) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Set-Content -Path "$dir\RustDesk2.toml" -Value $ServerConfig -Force
}

# Set the permanent password
& "$env:ProgramFiles\RustDesk\rustdesk.exe" --password $Password 2>$null

# Step 4: Start the service
Write-Host "[4/4] Starting RustDesk service..." -ForegroundColor Yellow
Start-Service -Name "RustDesk" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

# Get the ID
$RustDeskId = & "$env:ProgramFiles\RustDesk\rustdesk.exe" --get-id 2>$null

# Clean up
Remove-Item $InstallerPath -Force -ErrorAction SilentlyContinue

# Display results
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Your Remote Support ID:  $RustDeskId" -ForegroundColor White -BackgroundColor DarkBlue
Write-Host "  Your Password:           $Password" -ForegroundColor White -BackgroundColor DarkBlue
Write-Host ""
Write-Host "  Please share these with your Adriall" -ForegroundColor Yellow
Write-Host "  support technician so they can connect." -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Copy to clipboard
"ID: $RustDeskId | Password: $Password" | Set-Clipboard
Write-Host "  (Copied to clipboard)" -ForegroundColor DarkGray
Write-Host ""
Read-Host "Press Enter to close this window"
