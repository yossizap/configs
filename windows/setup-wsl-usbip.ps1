#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [string]$DistroName = "Ubuntu",
    [string]$BusId = "",
    [switch]$NoDistroInstall,
    [switch]$Bind,
    [switch]$Attach
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-Step {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    Write-Host "> $FilePath $($Arguments -join ' ')"
    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$FilePath exited with code $LASTEXITCODE"
    }
}

function Get-WslDistros {
    if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
        return @()
    }

    $distros = & wsl.exe --list --quiet 2>$null
    if ($LASTEXITCODE -ne 0 -or $null -eq $distros) {
        return @()
    }

    return @(
        $distros |
            ForEach-Object { ($_ -replace "`0", "").Trim([char]0xFEFF).Trim() } |
            Where-Object { $_ }
    )
}

function Ensure-Wsl {
    if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
        Write-Host "WSL command found."
        & wsl.exe --status *> $null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "WSL is not initialized; installing WSL without a distro first."
            Invoke-Step wsl.exe @("--install", "--no-distribution")
            Write-Warning "If Windows asks for a reboot, reboot and rerun this script."
        }
    } else {
        Write-Host "WSL command not found; enabling Windows optional features."
        Invoke-Step dism.exe @(
            "/online",
            "/enable-feature",
            "/featurename:Microsoft-Windows-Subsystem-Linux",
            "/all",
            "/norestart"
        )
        Invoke-Step dism.exe @(
            "/online",
            "/enable-feature",
            "/featurename:VirtualMachinePlatform",
            "/all",
            "/norestart"
        )
    }

    if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
        Invoke-Step wsl.exe @("--set-default-version", "2")
        return
    }

    Write-Warning "WSL features were enabled, but wsl.exe is not available in this session. Reboot Windows and rerun this script."
}

function Ensure-WslDistro {
    if ($NoDistroInstall) {
        return
    }

    $distros = Get-WslDistros
    if ($distros -contains $DistroName) {
        Write-Host "WSL distro '$DistroName' already installed."
        return
    }

    Write-Host "Installing WSL distro '$DistroName'."
    Invoke-Step wsl.exe @("--install", "-d", $DistroName)
    Write-Warning "If Windows asks for a reboot or Ubuntu asks for first-user setup, finish that and rerun this script."
}

function Ensure-UsbipdWin {
    if (Get-Command usbipd.exe -ErrorAction SilentlyContinue) {
        Write-Host "usbipd-win found."
        return
    }

    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
        throw "winget.exe was not found. Install App Installer from Microsoft Store, then rerun this script."
    }

    Write-Host "Installing usbipd-win with winget."
    Invoke-Step winget.exe @(
        "install",
        "--interactive",
        "--exact",
        "--id",
        "dorssel.usbipd-win",
        "--accept-package-agreements",
        "--accept-source-agreements"
    )
}

function Show-UsbipNextSteps {
    Write-Host ""
    Write-Host "FTDI / USB serial workflow:"
    Write-Host "  1. Plug in the FTDI adapter."
    Write-Host "  2. List devices:        usbipd list"
    Write-Host "  3. Bind once as admin:  usbipd bind --busid <busid>"
    Write-Host "  4. Attach to WSL:      usbipd attach --wsl --busid <busid>"
    Write-Host "  5. In WSL, verify:     lsusb; dmesg | tail; ls -l /dev/ttyUSB* /dev/ttyACM*"
    Write-Host "  6. Use serial:         picocom -b 115200 /dev/ttyUSB0"
    Write-Host ""
    Write-Host "After changing /etc/wsl.conf inside WSL, restart WSL once:"
    Write-Host "  wsl --shutdown"
}

if (-not (Test-Admin)) {
    throw "Run this script from an elevated PowerShell window."
}

Ensure-Wsl
Ensure-WslDistro
Ensure-UsbipdWin

if ($BusId) {
    if ($Bind) {
        Invoke-Step usbipd.exe @("bind", "--busid", $BusId)
    }
    if ($Attach) {
        Invoke-Step usbipd.exe @("attach", "--wsl", "--busid", $BusId)
    }
}

Write-Host ""
Write-Host "Current usbipd device list:"
& usbipd.exe list

Show-UsbipNextSteps
