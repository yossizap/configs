#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [string]$DistroName = "Ubuntu",
    [string]$BusId = "",
    [switch]$NoDistroInstall,
    [switch]$Bind,
    [switch]$Attach,
    [switch]$InstallDockerDesktop,
    [string]$WslMemory = "",
    [int]$WslProcessors = 0,
    [string]$WslSwap = ""
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

function Set-IniValue {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Section,
        [Parameter(Mandatory = $true)][string]$Key,
        [Parameter(Mandatory = $true)][string]$Value
    )

    $lines = [Collections.Generic.List[string]]::new()
    if (Test-Path -LiteralPath $Path) {
        foreach ($line in [IO.File]::ReadAllLines($Path)) {
            $lines.Add($line)
        }
    }

    $sectionPattern = "^\s*\[$([regex]::Escape($Section))\]\s*$"
    $keyPattern = "^\s*$([regex]::Escape($Key))\s*="
    $sectionIndex = -1
    $sectionEnd = $lines.Count

    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index] -match $sectionPattern) {
            $sectionIndex = $index
            continue
        }
        if ($sectionIndex -ge 0 -and $lines[$index] -match "^\s*\[.+\]\s*$") {
            $sectionEnd = $index
            break
        }
    }

    if ($sectionIndex -lt 0) {
        if ($lines.Count -gt 0 -and $lines[$lines.Count - 1]) {
            $lines.Add("")
        }
        $lines.Add("[$Section]")
        $lines.Add("$Key=$Value")
    } else {
        $keyIndex = -1
        for ($index = $sectionIndex + 1; $index -lt $sectionEnd; $index++) {
            if ($lines[$index] -match $keyPattern) {
                $keyIndex = $index
                break
            }
        }
        if ($keyIndex -ge 0) {
            $lines[$keyIndex] = "$Key=$Value"
        } else {
            $lines.Insert($sectionEnd, "$Key=$Value")
        }
    }

    [IO.File]::WriteAllLines($Path, $lines, [Text.UTF8Encoding]::new($false))
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
        Invoke-Step wsl.exe @("--update")
        Invoke-Step wsl.exe @("--set-default-version", "2")
        return
    }

    Write-Warning "WSL features were enabled, but wsl.exe is not available in this session. Reboot Windows and rerun this script."
}

function Set-WslNetworking {
    $wslConfig = Join-Path $env:USERPROFILE ".wslconfig"
    $windowsBuild = [int](Get-ItemPropertyValue `
        -LiteralPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" `
        -Name CurrentBuildNumber)

    if ($windowsBuild -lt 22621) {
        Write-Warning "Mirrored WSL networking requires Windows 11 22H2 or newer. Leaving $wslConfig unchanged."
        return
    }
    if ((Test-Path -LiteralPath $wslConfig) -and -not (Test-Path -LiteralPath "$wslConfig.bak")) {
        Copy-Item -LiteralPath $wslConfig -Destination "$wslConfig.bak"
    }

    Set-IniValue -Path $wslConfig -Section "wsl2" -Key "networkingMode" -Value "mirrored"
    Set-IniValue -Path $wslConfig -Section "wsl2" -Key "dnsTunneling" -Value "true"
    Set-IniValue -Path $wslConfig -Section "wsl2" -Key "autoProxy" -Value "true"
    Set-IniValue -Path $wslConfig -Section "wsl2" -Key "firewall" -Value "true"

    Write-Host "Configured mirrored networking, Windows DNS tunneling, proxy mirroring, and firewall integration in $wslConfig."
}

function Set-WslResourceLimits {
    if ($WslProcessors -lt 0) {
        throw "WSL processor count cannot be negative."
    }
    if (-not $WslMemory -and $WslProcessors -le 0 -and -not $WslSwap) {
        return
    }
    foreach ($size in @($WslMemory, $WslSwap)) {
        if ($size -and $size -notmatch "^[1-9]\d*(KB|MB|GB|TB)$") {
            throw "WSL memory and swap values must use a size such as 8GB or 512MB."
        }
    }

    $wslConfig = Join-Path $env:USERPROFILE ".wslconfig"
    if ((Test-Path -LiteralPath $wslConfig) -and -not (Test-Path -LiteralPath "$wslConfig.bak")) {
        Copy-Item -LiteralPath $wslConfig -Destination "$wslConfig.bak"
    }
    if ($WslMemory) {
        Set-IniValue -Path $wslConfig -Section "wsl2" -Key "memory" -Value $WslMemory
    }
    if ($WslProcessors -gt 0) {
        Set-IniValue -Path $wslConfig -Section "wsl2" -Key "processors" -Value "$WslProcessors"
    }
    if ($WslSwap) {
        Set-IniValue -Path $wslConfig -Section "wsl2" -Key "swap" -Value $WslSwap
    }

    Write-Host "Configured WSL resource limits in $wslConfig."
}

function Enable-WslSshFirewall {
    $creatorId = "{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}"
    $ruleName = "WSL-SSH"

    if (-not (Get-Command Get-NetFirewallHyperVRule -ErrorAction SilentlyContinue) -or
        -not (Get-Command New-NetFirewallHyperVRule -ErrorAction SilentlyContinue)) {
        Write-Warning "Hyper-V firewall cmdlets are unavailable. Allow TCP port 22 for WSL manually if LAN SSH access is required."
        return
    }

    $existing = Get-NetFirewallHyperVRule -Name $ruleName -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "WSL SSH Hyper-V firewall rule already exists."
        return
    }

    New-NetFirewallHyperVRule `
        -Name $ruleName `
        -DisplayName "WSL SSH" `
        -Direction Inbound `
        -VMCreatorId $creatorId `
        -Protocol TCP `
        -RemoteAddresses LocalSubnet `
        -LocalPorts 22 | Out-Null
    Write-Host "Allowed inbound SSH to WSL on TCP port 22."
}

function Ensure-WindowsWorkspace {
    $workspace = Join-Path $env:USERPROFILE "workspace"
    New-Item -ItemType Directory -Path $workspace -Force | Out-Null
    & fsutil.exe file setCaseSensitiveInfo $workspace enable *> $null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Could not enable case sensitivity for $workspace."
    }
    Write-Host "Windows-backed workspace: $workspace"
    Write-Host "Start WSL there with: cd `"$workspace`"; wsl.exe -d $DistroName"
}

function Ensure-WingetPackage {
    param(
        [Parameter(Mandatory = $true)][string]$Id,
        [Parameter(Mandatory = $true)][string]$Command,
        [Parameter(Mandatory = $true)][string]$DisplayName
    )

    if (Get-Command $Command -ErrorAction SilentlyContinue) {
        Write-Host "$DisplayName found."
        return
    }
    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
        throw "winget.exe was not found. Install App Installer from Microsoft Store, then rerun this script."
    }

    Write-Host "Installing $DisplayName with winget."
    Invoke-Step winget.exe @(
        "install",
        "--interactive",
        "--exact",
        "--id",
        $Id,
        "--accept-package-agreements",
        "--accept-source-agreements"
    )
}

function Install-DockerDesktop {
    if (-not $InstallDockerDesktop) {
        return
    }

    Ensure-WingetPackage -Id "Docker.DockerDesktop" -Command "docker.exe" -DisplayName "Docker Desktop"
    Invoke-Step wsl.exe @("--set-default", $DistroName)
    Write-Host "Docker Desktop uses its WSL 2 engine by default."
    Write-Host "After starting Docker Desktop, confirm $DistroName under Settings > Resources > WSL Integration."
}

function Enable-GitCredentialManager {
    Ensure-WingetPackage -Id "Git.Git" -Command "git.exe" -DisplayName "Git for Windows"
    if ((Get-WslDistros) -notcontains $DistroName) {
        Write-Warning "WSL distro '$DistroName' is not initialized; Git Credential Manager was not configured inside it."
        return
    }

    & wsl.exe -d $DistroName -- git --version *> $null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Git is not installed in '$DistroName'; Git Credential Manager was not configured inside it."
        return
    }

    Invoke-Step wsl.exe @("-d", $DistroName, "--", "git", "config", "--global", "credential.helper", "manager")
    Write-Host "WSL Git will use Git Credential Manager and Windows Credential Manager for HTTPS remotes."
}

function Install-WslSshKey {
    if ((Get-WslDistros) -notcontains $DistroName) {
        Write-Warning "WSL distro '$DistroName' is not initialized; the SSH key was not installed inside it."
        return
    }

    $sshDirectory = Join-Path $env:USERPROFILE ".ssh"
    $privateKey = Join-Path $sshDirectory "id_ed25519"
    $publicKey = "$privateKey.pub"
    New-Item -ItemType Directory -Path $sshDirectory -Force | Out-Null
    if (-not (Test-Path -LiteralPath $publicKey)) {
        Ensure-WindowsOpenSshClient
        if (Test-Path -LiteralPath $privateKey) {
            $publicKeyText = (& ssh-keygen.exe -y -f $privateKey) -join "`n"
            if ($LASTEXITCODE -ne 0) {
                throw "Could not recover the public key for $privateKey."
            }
            [IO.File]::WriteAllText(
                $publicKey,
                "$($publicKeyText.Trim())`n",
                [Text.UTF8Encoding]::new($false)
            )
        } else {
            Invoke-Step ssh-keygen.exe @("-t", "ed25519", "-f", $privateKey, "-N", "")
        }
    }

    $publicKeyText = ([IO.File]::ReadAllText($publicKey)).Trim()
    $script = 'umask 077; mkdir -p "$HOME/.ssh"; chmod 700 "$HOME/.ssh"; touch "$HOME/.ssh/authorized_keys"; chmod 600 "$HOME/.ssh/authorized_keys"; key=$1; grep -qxF "$key" "$HOME/.ssh/authorized_keys" || printf "%s\n" "$key" >> "$HOME/.ssh/authorized_keys"'
    Invoke-Step wsl.exe @("-d", $DistroName, "--", "sh", "-c", $script, "sh", $publicKeyText)
    Write-Host "Installed $publicKey for SSH access to $DistroName."
}

function Ensure-WindowsOpenSshClient {
    if (Get-Command ssh-keygen.exe -ErrorAction SilentlyContinue) {
        return
    }

    Write-Host "Installing the Windows OpenSSH client."
    Add-WindowsCapability -Online -Name "OpenSSH.Client~~~~0.0.1.0" | Out-Null
}

function Disable-WslSshPasswords {
    if ((Get-WslDistros) -notcontains $DistroName) {
        Write-Warning "WSL distro '$DistroName' is not initialized; SSH was not configured."
        return
    }

    $script = @'
if ! command -v sshd >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
        DEBIAN_FRONTEND=noninteractive apt-get update &&
            DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends openssh-server
    else
        exit 20
    fi
fi
mkdir -p /etc/ssh/sshd_config.d
if ! grep -qE '^[[:space:]]*Include[[:space:]]+/etc/ssh/sshd_config\.d/\*\.conf' /etc/ssh/sshd_config; then
    sed -i '1iInclude /etc/ssh/sshd_config.d/*.conf' /etc/ssh/sshd_config
fi
printf '%s\n' \
    'PasswordAuthentication no' \
    'KbdInteractiveAuthentication no' \
    'PermitRootLogin no' \
    > /etc/ssh/sshd_config.d/99-wsl-key-only.conf
mkdir -p /run/sshd
sshd -t || exit 21
if command -v systemctl >/dev/null 2>&1 && [ "$(ps -p 1 -o comm= 2>/dev/null)" = systemd ]; then
    systemctl enable --now ssh.service
elif command -v service >/dev/null 2>&1; then
    service ssh restart || service sshd restart
else
    pkill -HUP -x sshd 2>/dev/null || true
fi
'@
    & wsl.exe -d $DistroName -u root -- sh -c $script
    if ($LASTEXITCODE -eq 20) {
        Write-Warning "OpenSSH server is not installed in '$DistroName' and no supported package manager was found; key-only SSH was not configured."
        return
    }
    if ($LASTEXITCODE -ne 0) {
        throw "Could not configure key-only SSH in '$DistroName' (exit code $LASTEXITCODE)."
    }
    Write-Host "Disabled SSH password and root authentication in $DistroName."
}

function Enable-WindowsSudo {
    $windowsBuild = [int](Get-ItemPropertyValue `
        -LiteralPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" `
        -Name CurrentBuildNumber)
    if ($windowsBuild -ge 26100 -and (Get-Command sudo.exe -ErrorAction SilentlyContinue)) {
        Invoke-Step sudo.exe @("config", "--enable", "normal")
        Write-Host "Use sudo.exe from WSL when a Windows process needs UAC elevation."
        return
    }

    Ensure-WingetPackage -Id "gerardog.gsudo" -Command "gsudo.exe" -DisplayName "gsudo"
    Write-Host "Use gsudo.exe from WSL when a Windows process needs UAC elevation."
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

function Test-WslInterop {
    if ((Get-WslDistros) -notcontains $DistroName) {
        return
    }

    & wsl.exe -d $DistroName -- cmd.exe /c exit 0 *> $null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Windows executable interop is unavailable in '$DistroName'. Enable interop, Windows PATH appending, and drive mounting for the imported distribution."
        return
    }

    Write-Host "Windows executable interop works in $DistroName."
}

function Ensure-UsbipdWin {
    Ensure-WingetPackage -Id "dorssel.usbipd-win" -Command "usbipd.exe" -DisplayName "usbipd-win"
}

function Show-UsbipNextSteps {
    Write-Host ""
    Write-Host "WSL access after running install.sh inside the distro and restarting WSL:"
    Write-Host "  ssh <linux-user>@localhost"
    Write-Host "  scp <file> <linux-user>@localhost:<path>"
    Write-Host "  rsync -a -e ssh <path> <linux-user>@localhost:<path>"
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
Test-WslInterop
Set-WslNetworking
Set-WslResourceLimits
Enable-WslSshFirewall
Ensure-WindowsWorkspace
Install-DockerDesktop
Enable-GitCredentialManager
Install-WslSshKey
Disable-WslSshPasswords
Enable-WindowsSudo
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
