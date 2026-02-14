@echo off
:: Adriall Remote Support — Double-click to install
:: This downloads and runs the PowerShell installer

echo.
echo ========================================
echo   Adriall Remote Support Setup
echo ========================================
echo.
echo Starting installation...
echo.

powershell.exe -ExecutionPolicy Bypass -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $script = (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/brandenlwwood/adriall-support/main/install-rustdesk.ps1'); Invoke-Expression $script }"

pause
