<#
    Oh My Posh Auto Installer (SAFE VERSION)
#>

# ==============================
# ⚙️ GLOBAL SETTINGS
# ==============================
$ErrorActionPreference = "Stop"

# Globalny handler błędów
trap {
    Write-Host "`n❌ Wystąpił błąd:" -ForegroundColor Red
    Write-Host $_ -ForegroundColor DarkRed
    Write-Host "`nNaciśnij ENTER aby zamknąć..." -ForegroundColor Yellow
    Read-Host
    break
}

Write-Host "`n[🔧] Uruchamianie instalatora Oh My Posh..." -ForegroundColor Cyan

# ==============================
# 🔍 FUNCTIONS
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

function Ensure-PS7 {
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Stop-Script "Wymagana wersja PowerShell 7+"
    }
}

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
        if (Test-Path $tmp) {
            Remove-Item $tmp -Force -ErrorAction SilentlyContinue
        }
    }
}

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

function Update-Profile {
    Write-Host "`n📝 Aktualizacja profilu..." -ForegroundColor Gray

    if (-not (Test-Path $PROFILE)) {
        New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    }

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

Ensure-PS7
Test-Internet

Install-OhMyPosh
Install-Font
Install-TerminalIcons
Update-Profile

# ==============================
# 📌 END
# ==============================

Write-Host "`n------------------------------------------------------------" -ForegroundColor White
Write-Host "✅ Instalacja zakończona!" -ForegroundColor Green
Write-Host "Naciśnij ENTER aby zamknąć..." -ForegroundColor Yellow
Read-Host
