# =====================================================
# ⚡ Oh My Posh PowerShell Auto-Installer V5
# =====================================================

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "`n[🔧] Uruchamianie instalatora Oh My Posh..." -ForegroundColor Cyan

# --------------------------
# 1️⃣ Sprawdzenie PowerShell 7+
# --------------------------
function Ensure-PS7 {
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Host "[⚠️] Wymagana wersja PowerShell 7 lub wyższa!" -ForegroundColor Yellow
        Write-Host "📥 Pobieranie PowerShell 7..." -ForegroundColor Gray
        try {
            # Pobierz najnowszy instalator MSI dla Windows x64
            $ps7Msi = "$env:TEMP\PowerShell-7.msi"
            $latestUrl = "https://github.com/PowerShell/PowerShell/releases/latest"
            $response = Invoke-WebRequest $latestUrl -UseBasicParsing -MaximumRedirection 5
            $version = $response.BaseResponse.RequestMessage.RequestUri.Segments[-1].TrimStart('v')
            $msiUrl = "https://github.com/PowerShell/PowerShell/releases/download/v$version/PowerShell-$version-win-x64.msi"

            Invoke-WebRequest $msiUrl -OutFile $ps7Msi -UseBasicParsing
            Write-Host "🚀 Instalacja PowerShell 7 ($version)..." -ForegroundColor Cyan
            Start-Process msiexec.exe -ArgumentList "/i `"$ps7Msi`" /qn /norestart" -Wait
            Remove-Item $ps7Msi -Force
            Write-Host "✅ PowerShell 7 zainstalowany. Uruchom ponownie terminal jako pwsh!" -ForegroundColor Green
            exit
        } catch {
            Write-Host "❌ Nie udało się zainstalować PowerShell 7: $_" -ForegroundColor Red
            Write-Host "👉 Zainstaluj ręcznie: https://aka.ms/install-powershell" -ForegroundColor Yellow
            exit
        }
    } else {
        Write-Host "✔️ PowerShell $($PSVersionTable.PSVersion) wykryty." -ForegroundColor Green
    }
}
Ensure-PS7

# --------------------------
# 2️⃣ Sprawdzenie internetu
# --------------------------
Write-Host "`n🌐 Sprawdzanie połączenia z internetem..." -ForegroundColor Gray
try {
    $null = Invoke-WebRequest "https://github.com" -UseBasicParsing -TimeoutSec 5
    Write-Host "✔️ Połączenie z internetem OK." -ForegroundColor Green
} catch {
    Write-Host "❌ Brak połączenia z GitHub. Przerwano instalację." -ForegroundColor Red
    exit
}

# --------------------------
# 3️⃣ Instalacja Oh My Posh
# --------------------------
$ompExe = "$env:LOCALAPPDATA\Programs\oh-my-posh\bin\oh-my-posh.exe"
if (-not (Test-Path $ompExe)) {
    Write-Host "`n📦 Pobieranie i instalacja Oh My Posh..." -ForegroundColor White
    winget install JanDeDobbeleer.OhMyPosh -s winget --silent --accept-package-agreements --accept-source-agreements
    # Odśwież PATH w bieżącej sesji
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "User")
    Write-Host "✅ Oh My Posh zainstalowany!" -ForegroundColor Green
} else {
    Write-Host "✔️ Oh My Posh już zainstalowany." -ForegroundColor Gray
}

# Weryfikacja czy oh-my-posh jest dostępny
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    # Spróbuj bezpośredniej ścieżki
    if (Test-Path $ompExe) {
        $env:PATH += ";$env:LOCALAPPDATA\Programs\oh-my-posh\bin"
    } else {
        Write-Host "❌ oh-my-posh nie jest dostępny w PATH. Sprawdź instalację." -ForegroundColor Red
        exit
    }
}

# --------------------------
# 4️⃣ Pobranie motywu
# --------------------------
$themesFolder = "$env:USERPROFILE\Documents\PowerShell\PoshThemes"
if (-not (Test-Path $themesFolder)) {
    New-Item -ItemType Directory -Path $themesFolder -Force | Out-Null
}

# Użyj absolutnej ścieżki — NIE zmiennej środowiskowej, żeby profil był zawsze poprawny
$themePath = "$themesFolder\jandedobbeleer.omp.json"
$themeUrl  = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/jandedobbeleer.omp.json"

Write-Host "`n🎨 Pobieranie motywu Oh My Posh..." -ForegroundColor White
Invoke-WebRequest $themeUrl -OutFile $themePath -UseBasicParsing
Write-Host "✅ Motyw zapisany: $themePath" -ForegroundColor Green

# --------------------------
# 5️⃣ Instalacja Terminal-Icons
# --------------------------
Write-Host "`n📦 Sprawdzanie modułu Terminal-Icons..." -ForegroundColor White
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
    try {
        # Pobierz aktualną wersję z GitHub API
        $nfRelease = Invoke-RestMethod "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"
        $nfVersion = $nfRelease.tag_name
        $fontZipUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/$nfVersion/Cousine.zip"

        Write-Host "📥 Pobieranie Cousine Nerd Font $nfVersion..." -ForegroundColor Gray
        $fontZip = "$env:TEMP\Cousine.zip"
        Invoke-WebRequest $fontZipUrl -OutFile $fontZip -UseBasicParsing
        Expand-Archive $fontZip -DestinationPath "$env:TEMP\Cousine" -Force

        $shell = New-Object -ComObject Shell.Application
        $fontsFolder = $shell.Namespace(0x14)
        Get-ChildItem "$env:TEMP\Cousine" -Include '*.ttf','*.otf','*.ttc' -Recurse | ForEach-Object {
            $tempFont = "$env:TEMP\$($_.Name)"
            Copy-Item $_.FullName $tempFont -Force
            $fontsFolder.CopyHere($tempFont, 0x10)
            Remove-Item $tempFont -Force
        }

        Remove-Item "$env:TEMP\Cousine" -Recurse -Force
        Remove-Item $fontZip -Force
        Write-Host "✅ Czcionka Cousine Nerd Font zainstalowana!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Nie udało się zainstalować czcionki: $_" -ForegroundColor Red
    }
} else {
    Write-Host "⏭️ Pominięto instalację czcionki." -ForegroundColor Yellow
}

# --------------------------
# 7️⃣ Aktualizacja profilu PowerShell
# --------------------------

# Upewnij się że plik profilu istnieje
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    Write-Host "📄 Utworzono plik profilu: $PROFILE" -ForegroundColor Gray
}

if (Select-String -Path $PROFILE -Pattern "### OMP CONFIG START ###" -Quiet) {
    Write-Host "✔️ Profil PowerShell już zawiera konfigurację Oh My Posh." -ForegroundColor Gray
} else {
    Write-Host "`n📝 Konfiguracja PowerShell profile..." -ForegroundColor Gray

    # WAŻNE: używamy tutaj zwykłych stringów (""), żeby $themePath i inne zmienne
    # zostały rozwinięte do prawdziwych ścieżek — nie literalnych nazw zmiennych.
    $profileContent = @"

### OMP CONFIG START ###
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "$themePath" | Invoke-Expression
}
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
}
### OMP CONFIG END ###
"@

    Add-Content -Path $PROFILE -Value $profileContent
    Write-Host "✅ Profil PowerShell zaktualizowany!" -ForegroundColor Green
}

# --------------------------
# 8️⃣ Podsumowanie
# --------------------------
Write-Host "`n------------------------------------------------------------" -ForegroundColor White
Write-Host "✅ Instalacja zakończona pomyślnie!" -ForegroundColor Green
Write-Host "`n📌 Co dalej?" -ForegroundColor Cyan
Write-Host "  1) Zamknij i otwórz nowe okno PowerShell 7 (pwsh)" -ForegroundColor Yellow
Write-Host "  2) Jeśli zainstalowano czcionkę — w ustawieniach terminala" -ForegroundColor Yellow
Write-Host "     ustaw czcionkę: Cousine Nerd Font" -ForegroundColor Yellow
Write-Host "`n📁 Motyw zapisany w:" -ForegroundColor Gray
Write-Host "  $themePath" -ForegroundColor White
Write-Host "📁 Profil PowerShell:" -ForegroundColor Gray
Write-Host "  $PROFILE" -ForegroundColor White
Write-Host "------------------------------------------------------------`n" -ForegroundColor White
