<# 
    Auto Installer for Oh My Posh with Fonts & Terminal-Icons
    Source: https://github.com/JanDeDobbeleer/oh-my-posh
#>

Write-Host "`n[🔧] Uruchamianie instalatora Oh My Posh..." -ForegroundColor Cyan

# Wymagany PowerShell 7+
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "[⚠️] Wymagana wersja PowerShell 7 lub wyższa!" -ForegroundColor Yellow
    Write-Host "📥 Pobierz: https://github.com/PowerShell/PowerShell" -ForegroundColor Yellow
    exit
}

# Sprawdzenie połączenia z GitHub
Write-Host "`n🌐 Sprawdzanie połączenia z GitHub..." -ForegroundColor Gray
if (-not (Test-Connection -ComputerName github.com -Count 1 -Quiet)) {
    Write-Host "❌ Brak połączenia z GitHub. Przerwano instalację." -ForegroundColor Red
    exit
}

# Detekcja architektury
$installer = if ([Environment]::Is64BitOperatingSystem) { "posh-windows-amd64.exe" } else { "posh-windows-386.exe" }
$url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/$installer"

# Pobranie Oh My Posh
Write-Host "`n📦 Pobieranie: $installer..." -ForegroundColor White
$tmpInstaller = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'exe' } -PassThru

try {
    Invoke-WebRequest -Uri $url -OutFile $tmpInstaller -UseBasicParsing -ErrorAction Stop
    Write-Host "✅ Pobrano pomyślnie!" -ForegroundColor Green
} catch {
    Write-Host "❌ Błąd pobierania: $_" -ForegroundColor Red
    exit
}

# Uruchomienie instalatora
Write-Host "`n🚀 Instalacja Oh My Posh..." -ForegroundColor Cyan
& $tmpInstaller /VERYSILENT "/CURRENTUSER"
Remove-Item $tmpInstaller -Force

# Font – pytanie
$fontAnswer = Read-Host "`n🖋️ Czy chcesz zainstalować czcionkę Cousine NFM? (y/n)"
if ($fontAnswer -ieq "y") {
    Write-Host "`n📦 Pobieranie czcionki Cousine Nerd Font..."
    $tmpZip = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'zip' } -PassThru
    $fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Cousine.zip"

    try {
        Invoke-WebRequest -Uri $fontUrl -OutFile $tmpZip -UseBasicParsing -ErrorAction Stop
        Write-Host "✅ Pobrano czcionkę!" -ForegroundColor Green

        $fontFolder = "$env:TEMP\Cousine"
        Expand-Archive -Path $tmpZip -DestinationPath $fontFolder -Force

        function Install-Fonts($sourceDir) {
            $Destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
            Get-ChildItem -Path $sourceDir -Include '*.ttf','*.otf','*.ttc' -Recurse | ForEach-Object {
                $fontTarget = "$env:windir\Fonts\$($_.Name)"
                if (-not (Test-Path $fontTarget)) {
                    $tempFont = "$env:TEMP\$($_.Name)"
                    Copy-Item $_.FullName -Destination $tempFont
                    $Destination.CopyHere($tempFont, 0x10)
                    Remove-Item $tempFont -Force
                }
            }
        }

        Write-Host "🖨️ Instalacja czcionek..."
        Install-Fonts $fontFolder
        Remove-Item $fontFolder -Recurse -Force
        Remove-Item $tmpZip -Force
        Write-Host "✅ Czcionka Cousine NFM zainstalowana!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Błąd instalacji czcionki: $_" -ForegroundColor Red
    }
} else {
    Write-Host "⏭️ Pominięto instalację czcionki." -ForegroundColor Yellow
}

# Instalacja Terminal-Icons
Write-Host "`n📦 Instalacja modułu Terminal-Icons..."
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    try {
        Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
        Write-Host "✅ Terminal-Icons zainstalowano!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Błąd instalacji Terminal-Icons: $_" -ForegroundColor Red
    }
} else {
    Write-Host "✔️ Terminal-Icons już zainstalowany." -ForegroundColor Gray
}

# Modyfikacja profilu PowerShell
if (-not (Select-String -Path $PROFILE -Pattern "Generated - START" -Quiet)) {
    Write-Host "`n📝 Modyfikacja pliku profilu: $PROFILE" -ForegroundColor Gray
    Add-Content -Path $PROFILE -Value "`n### Generated - START ###"
    Add-Content -Path $PROFILE -Value 'if ($PSVersionTable.PSVersion.Major -ge 7) {'
    Add-Content -Path $PROFILE -Value '    Import-Module Terminal-Icons'
    Add-Content -Path $PROFILE -Value '    oh-my-posh init pwsh | Invoke-Expression'
    Add-Content -Path $PROFILE -Value '}'
    Add-Content -Path $PROFILE -Value "### Generated - END ###"
    Write-Host "✅ Zaktualizowano profil PowerShell." -ForegroundColor Green
} else {
    Write-Host "✔️ Profil PowerShell już zawiera konfigurację Oh My Posh." -ForegroundColor Gray
}

# Podsumowanie
Write-Host "`n------------------------------------------------------------" -ForegroundColor White
Write-Host "✅ Instalacja zakończona pomyślnie!" -ForegroundColor Green
Write-Host "📌 Co dalej?" -ForegroundColor Cyan
Write-Host "1) Uruchom ponownie PowerShell 7" -ForegroundColor Yellow
Write-Host "2) Otwórz ustawienia terminala" -ForegroundColor Yellow
Write-Host "3) Wybierz czcionkę: Cousine NFM" -ForegroundColor Yellow
Write-Host "------------------------------------------------------------" -ForegroundColor White
