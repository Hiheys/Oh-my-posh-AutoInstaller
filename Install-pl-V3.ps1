<#
    Oh My Posh Auto Installer (SAFE + Auto PS7)
    Includes: PowerShell 7+, Oh My Posh, Nerd Fonts, Terminal-Icons
#>

# ==============================
# ⚙️ GLOBAL SETTINGS
# ==============================
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

trap {
    Write-Host "`n❌ Wystąpił błąd:" -ForegroundColor Red
    Write-Host $_ -ForegroundColor DarkRed
    Write-Host "`nNaciśnij ENTER aby zakończyć..." -ForegroundColor Yellow
    Read-Host
    break
}

Write-Host "`n[🔧] Uruchamianie instalatora Oh My Posh..." -ForegroundColor Cyan

# ==============================
# 🔍 HELPER FUNCTIONS
# ==============================

function Stop-Script($msg) {
    Write-Host "`n❌ $msg" -ForegroundColor Red
    Write-Host "`nNaciśnij ENTER aby zakończyć..." -ForegroundColor Yellow
    Read-Host
    return
}

function Test-Internet {
    Write-Host "`n🌐 Sprawdzanie internetu..." -ForegroundColor Gray
    try {
        Invoke-WebRequest "https://github.com" -Method Head -TimeoutSec 5 | Out-Null
    } catch {
        Stop-Script "Brak połączenia z internetem."
    }
}

# ==============================
# ⚡ POWERHELL 7+
# ==============================
function Ensure-PS7 {
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        Write-Host "✔️ PowerShell 7+ wykryty." -ForegroundColor Green
        return
    }

    Write-Host "[⚠️] Wymagana wersja PowerShell 7+" -ForegroundColor Yellow
    Write-Host "📥 Instalacja PowerShell 7..." -ForegroundColor Cyan

    # Pobranie MSI (x64)
    $ps7Version = "7.4.8"
    $installerUrl = "https://github.com/PowerShell/PowerShell/releases/download/v$ps7Version/PowerShell-$ps7Version-win-x64.msi"
    $tmpInstaller = Join-Path $env:TEMP "PowerShell-$ps7Version-win-x64.msi"

    try {
        Write-Host "🌐 Pobieranie PowerShell 7 z GitHub..." -ForegroundColor Gray
        Invoke-WebRequest -Uri $installerUrl -OutFile $tmpInstaller -UseBasicParsing -ErrorAction Stop
        Write-Host "✅ Pobrano PowerShell 7!" -ForegroundColor Green

        Write-Host "🚀 Uruchamianie instalatora PowerShell 7..." -ForegroundColor Cyan
        Start-Process "msiexec.exe" -ArgumentList "/i `"$tmpInstaller`" /qn /norestart" -Wait
        Write-Host "✅ PowerShell 7 zainstalowany!" -ForegroundColor Green
    } catch {
        Stop-Script "Nie udało się zainstalować PowerShell 7: $_"
    } finally {
        if (Test-Path $tmpInstaller) { Remove-Item $tmpInstaller -Force }
    }

    Write-Host "`n[ℹ️] Zamknij ten PowerShell i uruchom PowerShell 7, a następnie uruchom instalator ponownie." -ForegroundColor Cyan
    return
}

# ==============================
# ⚡ OH MY POSH
# ==============================
function Download-File($url, $output) {
    try {
        Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
        return $true
    } catch {
        Write-Host "❌ Błąd pobierania: $url" -ForegroundColor Red
        return $false
    }
}

function Install-OhMyPosh {
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        Write-Host "✔️ Oh My Posh już zainstalowany." -ForegroundColor Gray
        return
    }

    Write-Host "`n📦 Instalacja Oh My Posh..." -ForegroundColor White

    $installer = if ([Environment]::Is64BitOperatingSystem) {
        "posh-windows-amd64.exe"
    } else {
        "posh-windows-386.exe"
    }

    $url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/$installer"
    $tmp = Join-Path $env:TEMP $installer

    try {
        if (Download-File $url $tmp) {
            & $tmp /VERYSILENT "/CURRENTUSER"
            Write-Host "✅ Oh My Posh zainstalowany!" -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ Instalacja Oh My Posh nie powiodła się." -ForegroundColor Red
    } finally {
        if (Test-Path $tmp) { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
    }
}

# ==============================
# ⚡ NERD FONT
# ==============================
function Install-Font {
    do {
        $choice = Read-Host "`n🖋️ Zainstalować Cousine Nerd Font? (y/n)"
    } while ($choice -notin @("y","n"))

    if ($choice -ne "y") {
        Write-Host "⏭️ Pominięto font." -ForegroundColor Yellow
        return
    }

    Write-Host "`n📦 Instalacja czcionki..." -ForegroundColor White

    $zipUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Cousine.zip"
    $zipPath = Join-Path $env:TEMP "font.zip"
    $extractPath = Join-Path $env:TEMP "font"

    try {
        if (Download-File $zipUrl $zipPath) {
            Expand-Archive $zipPath -DestinationPath $extractPath -Force

            $fonts = Get-ChildItem -Path $extractPath -Include *.ttf, *.otf -Recurse
            $shell = New-Object -ComObject Shell.Application
            $fontsFolder = $shell.Namespace(0x14)

            foreach ($font in $fonts) {
                $target = "$env:WINDIR\Fonts\$($font.Name)"
                if (-not (Test-Path $target)) {
                    $fontsFolder.CopyHere($font.FullName, 0x10)
                }
            }

            Write-Host "✅ Czcionka zainstalowana!" -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ Błąd instalacji czcionki." -ForegroundColor Red
    } finally {
        Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
        Remove-Item $extractPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ==============================
# ⚡ TERMINAL-ICONS
# ==============================
function Install-TerminalIcons {
    Write-Host "`n📦 Instalacja Terminal-Icons..." -ForegroundColor White

    if (Get-Module -ListAvailable -Name Terminal-Icons) {
        Write-Host "✔️ Terminal-Icons już jest." -ForegroundColor Gray
        return
    }

    try {
        Set-PSRepository PSGallery -InstallationPolicy Trusted
        Install-Module Terminal-Icons -Scope CurrentUser -Force -AllowClobber
        Write-Host "✅ Terminal-Icons zainstalowany!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Instalacja Terminal-Icons nie powiodła się." -ForegroundColor Red
    }
}

# ==============================
# ⚡ PROFIL POWERSHELL
# ==============================
function Update-Profile {
    Write-Host "`n📝 Aktualizacja profilu..." -ForegroundColor Gray

    if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }

    if (Select-String -Path $PROFILE -Pattern "### OMP CONFIG START ###" -Quiet) {
        Write-Host "✔️ Profil już skonfigurowany." -ForegroundColor Gray
        return
    }

    Add-Content $PROFILE @"
### OMP CONFIG START ###
if (`$PSVersionTable.PSVersion.Major -ge 7) {
    Import-Module Terminal-Icons
    oh-my-posh init pwsh --config "`$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" | Invoke-Expression
}
### OMP CONFIG END ###
"@

    Write-Host "✅ Profil zaktualizowany!" -ForegroundColor Green
}

# ==============================
# 🚀 EXECUTION
# ==============================
Test-Internet
Ensure-PS7
Install-OhMyPosh
Install-Font
Install-TerminalIcons
Update-Profile

# ==============================
# 📌 SUMMARY
# ==============================
Write-Host "`n------------------------------------------------------------" -ForegroundColor White
Write-Host "✅ Instalacja zakończona!" -ForegroundColor Green
Write-Host "📌 Następne kroki:" -ForegroundColor Cyan
Write-Host "1) Uruchom PowerShell 7" -ForegroundColor Yellow
Write-Host "2) Ustaw font: Cousine Nerd Font w terminalu" -ForegroundColor Yellow
Write-Host "3) Ciesz się Oh My Posh + Terminal-Icons!" -ForegroundColor Yellow
Write-Host "------------------------------------------------------------" -ForegroundColor White
Write-Host "`nNaciśnij ENTER aby zakończyć..." -ForegroundColor Yellow
Read-Host
