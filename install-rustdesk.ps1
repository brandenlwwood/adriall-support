# ============================================================
# Remote Support — RustDesk Installer for Windows
# Usage: install-rustdesk.ps1 -Server <host> -Key <key> [-Name <company>] [-Version <ver>]
# ============================================================

param(
    [Parameter(Mandatory=$true)][string]$Server,
    [Parameter(Mandatory=$true)][string]$Key,
    [string]$Name = "Remote Support",
    [string]$Version = "1.4.1"
)

$ErrorActionPreference = "Stop"
$DownloadUrl = "https://github.com/rustdesk/rustdesk/releases/download/$Version/rustdesk-$Version-x86_64.exe"
$InstallerPath = "$env:TEMP\rustdesk-installer.exe"

$ServerConfig = @"
rendezvous_server = '${Server}:21116'
nat_type = 1
serial = 0
unlock_pin = ''

[options]
custom-rendezvous-server = '$Server'
relay-server = '$Server'
api-server = 'http://${Server}:21116'
key = '$Key'
"@

# Generate a random 8-character password
$Password = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 8 | ForEach-Object { [char]$_ })

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  $Name Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check for admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Restarting as Administrator..." -ForegroundColor Yellow
    $argList = "-ExecutionPolicy Bypass -File `"$PSCommandPath`" -Server `"$Server`" -Key `"$Key`" -Name `"$Name`" -Version `"$Version`""
    Start-Process powershell.exe $argList -Verb RunAs
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
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 2: Install silently
Write-Host "[2/4] Installing RustDesk..." -ForegroundColor Yellow
Start-Process -FilePath $InstallerPath -ArgumentList "--silent-install" -Wait
Start-Sleep -Seconds 5
Write-Host "       Installed successfully." -ForegroundColor Green

# Step 3: Stop the service and configure
Write-Host "[3/4] Configuring for $Name..." -ForegroundColor Yellow
Stop-Service -Name "RustDesk" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

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

& "$env:ProgramFiles\RustDesk\rustdesk.exe" --password $Password 2>$null

# Step 4: Start the service
Write-Host "[4/4] Starting RustDesk service..." -ForegroundColor Yellow
Start-Service -Name "RustDesk" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

$RustDeskId = & "$env:ProgramFiles\RustDesk\rustdesk.exe" --get-id 2>$null

Remove-Item $InstallerPath -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Your Remote Support ID:  $RustDeskId" -ForegroundColor White -BackgroundColor DarkBlue
Write-Host "  Your Password:           $Password" -ForegroundColor White -BackgroundColor DarkBlue
Write-Host ""
Write-Host "  Please share these with your" -ForegroundColor Yellow
Write-Host "  support technician so they can connect." -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

"ID: $RustDeskId | Password: $Password" | Set-Clipboard
Write-Host "  (Copied to clipboard)" -ForegroundColor DarkGray
Write-Host ""
Read-Host "Press Enter to close this window"
