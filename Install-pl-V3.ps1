# =====================================================
# ⚡ Oh My Posh PowerShell Auto-Installer V4
# =====================================================

# Ustawienia podstawowe
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "`n[🔧] Uruchamianie instalatora Oh My Posh..." -ForegroundColor Cyan

# --------------------------
# 1️⃣ Sprawdzenie PowerShell 7+
# --------------------------
function Ensure-PS7 {
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Host "[⚠️] Wymagana wersja PowerShell 7 lub wyższa!" -ForegroundColor Yellow
        $ps7Msi = "$env:TEMP\PowerShell-7.msi"
        Write-Host "📥 Pobieranie PowerShell 7..." -ForegroundColor Gray
        try {
            Invoke-WebRequest "https://aka.ms/win64ps7" -OutFile $ps7Msi -UseBasicParsing
            Write-Host "🚀 Instalacja PowerShell 7..." -ForegroundColor Cyan
            Start-Process msiexec.exe -ArgumentList "/i `"$ps7Msi`" /qn /norestart" -Wait
            Remove-Item $ps7Msi -Force
            Write-Host "✅ PowerShell 7 zainstalowany. Uruchom ponownie terminal!" -ForegroundColor Green
            exit
        } catch {
            Write-Host "❌ Nie udało się zainstalować PowerShell 7: $_" -ForegroundColor Red
            exit
        }
    } else {
        Write-Host "✔️ PowerShell 7 wykryty." -ForegroundColor Green
    }
}
Ensure-PS7

# --------------------------
# 2️⃣ Sprawdzenie internetu
# --------------------------
Write-Host "`n🌐 Sprawdzanie połączenia z internetem..." -ForegroundColor Gray
if (-not (Test-Connection -ComputerName github.com -Count 1 -Quiet)) {
    Write-Host "❌ Brak połączenia z GitHub. Przerwano instalację." -ForegroundColor Red
    exit
} else {
    Write-Host "✔️ Połączenie z internetem OK." -ForegroundColor Green
}

# --------------------------
# 3️⃣ Instalacja Oh My Posh
# --------------------------
$ompInstaller = "$env:LOCALAPPDATA\Programs\oh-my-posh\bin\oh-my-posh.exe"
if (-not (Test-Path $ompInstaller)) {
    Write-Host "`n📦 Pobieranie i instalacja Oh My Posh..." -ForegroundColor White
    Invoke-Expression "winget install JanDeDobbeleer.OhMyPosh -s winget --silent --accept-package-agreements"
} else {
    Write-Host "✔️ Oh My Posh już zainstalowany." -ForegroundColor Gray
}

# --------------------------
# 4️⃣ Pobranie motywu
# --------------------------
$themesFolder = "$env:USERPROFILE\Documents\PowerShell\PoshThemes"
if (-not (Test-Path $themesFolder)) { New-Item -ItemType Directory -Path $themesFolder | Out-Null }

$themeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/jandedobbeleer.omp.json"
$themePath = Join-Path $themesFolder "jandedobbeleer.omp.json"

Write-Host "`n🎨 Pobieranie motywu Oh My Posh..." -ForegroundColor White
Invoke-WebRequest $themeUrl -OutFile $themePath -UseBasicParsing

# --------------------------
# 5️⃣ Instalacja Terminal-Icons
# --------------------------
Write-Host "`n📦 Instalacja modułu Terminal-Icons..." -ForegroundColor White
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser -Force -AllowClobber
    Write-Host "✅ Terminal-Icons zainstalowany!" -ForegroundColor Green
} else {
    Write-Host "✔️ Terminal-Icons już zainstalowany." -ForegroundColor Gray
}

# --------------------------
# 6️⃣ Opcjonalna czcionka Cousine Nerd Font
# --------------------------
$fontAnswer = Read-Host "`n🖋️ Czy chcesz zainstalować czcionkę Cousine Nerd Font? (y/n)"
if ($fontAnswer -ieq "y") {
    $fontZip = "$env:TEMP\Cousine.zip"
    Invoke-WebRequest "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Cousine.zip" -OutFile $fontZip -UseBasicParsing
    Expand-Archive $fontZip -DestinationPath "$env:TEMP\Cousine" -Force

    $Destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
    Get-ChildItem "$env:TEMP\Cousine" -Include '*.ttf','*.otf','*.ttc' -Recurse | ForEach-Object {
        $tempFont = "$env:TEMP\$($_.Name)"
        Copy-Item $_.FullName $tempFont
        $Destination.CopyHere($tempFont, 0x10)
        Remove-Item $tempFont -Force
    }

    Remove-Item "$env:TEMP\Cousine" -Recurse -Force
    Remove-Item $fontZip -Force
    Write-Host "✅ Czcionka Cousine Nerd Font zainstalowana!" -ForegroundColor Green
} else {
    Write-Host "⏭️ Pominięto instalację czcionki." -ForegroundColor Yellow
}

# --------------------------
# 7️⃣ Aktualizacja profilu PowerShell
# --------------------------
if (-not (Select-String -Path $PROFILE -Pattern "### OMP CONFIG START ###" -Quiet)) {
    Write-Host "`n📝 Konfiguracja PowerShell profile..." -ForegroundColor Gray
    Add-Content -Path $PROFILE -Value "`n### OMP CONFIG START ###"
    Add-Content -Path $PROFILE -Value "if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {"
    Add-Content -Path $PROFILE -Value "    oh-my-posh init pwsh --config `"$themePath`" | Invoke-Expression"
    Add-Content -Path $PROFILE -Value "}"
    Add-Content -Path $PROFILE -Value "### OMP CONFIG END ###"
    Write-Host "✅ Profil PowerShell zaktualizowany!" -ForegroundColor Green
} else {
    Write-Host "✔️ Profil PowerShell już zawiera konfigurację Oh My Posh." -ForegroundColor Gray
}

# --------------------------
# 8️⃣ Podsumowanie
# --------------------------
Write-Host "`n------------------------------------------------------------" -ForegroundColor White
Write-Host "✅ Instalacja zakończona pomyślnie!" -ForegroundColor Green
Write-Host "📌 Co dalej?" -ForegroundColor Cyan
Write-Host "1) Zamknij i otwórz PowerShell 7 (pwsh)" -ForegroundColor Yellow
Write-Host "2) W ustawieniach terminala wybierz czcionkę: Cousine Nerd Font" -ForegroundColor Yellow
Write-Host "------------------------------------------------------------" -ForegroundColor White
