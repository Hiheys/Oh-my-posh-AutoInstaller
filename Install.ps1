<#
.SYNOPSIS
    Oh My Posh Auto-Installer (PL/EN) - unified version
.DESCRIPTION
    Single script replacing Install-pl.ps1 / Install-pl-V3.ps1 / Install-en.ps1.
    Language is chosen at startup (or set $env:OMP_LANG = "pl"/"en" before running).
.NOTES
    Remote usage:
      Set-ExecutionPolicy Bypass -Scope Process -Force
      irm https://raw.githubusercontent.com/Hiheys/Oh-my-posh-AutoInstaller/main/Install.ps1 | iex

    Non-interactive usage (e.g. automation):
      $env:OMP_LANG = "en"
      irm https://raw.githubusercontent.com/Hiheys/Oh-my-posh-AutoInstaller/main/Install.ps1 | iex
#>

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ============================================================
# 1. LANGUAGE SELECTION / DETECTION
# ============================================================
function Get-InstallerLanguage {
    if ($env:OMP_LANG -in @("pl", "en")) {
        return $env:OMP_LANG
    }

    $detected = if ((Get-Culture).TwoLetterISOLanguageName -eq "pl") { "pl" } else { "en" }

    Write-Host ""
    Write-Host "Select language / Wybierz jezyk:" -ForegroundColor Cyan
    Write-Host "  [1] Polski"
    Write-Host "  [2] English"
    $choice = Read-Host "Twoj wybor / Your choice (Enter = $detected)"

    switch ($choice) {
        "1"     { return "pl" }
        "2"     { return "en" }
        default { return $detected }
    }
}

$Lang = Get-InstallerLanguage

# ============================================================
# 2. STRING TABLE (i18n) - single place to edit/translate
# ============================================================
$Strings = @{
    pl = @{
        starting          = "`n[konfig] Uruchamianie instalatora Oh My Posh..."
        ps7_missing       = "[uwaga] Wymagana wersja PowerShell 7 lub wyzsza!"
        ps7_downloading   = "Pobieranie PowerShell 7..."
        ps7_installing    = "Instalacja PowerShell 7 ({0})..."
        ps7_done          = "PowerShell 7 zainstalowany. Uruchom ponownie terminal jako pwsh!"
        ps7_fail          = "Nie udalo sie zainstalowac PowerShell 7: {0}"
        ps7_manual        = "Zainstaluj recznie: https://aka.ms/install-powershell"
        ps7_ok            = "PowerShell {0} wykryty."
        net_checking      = "`nSprawdzanie polaczenia z internetem..."
        net_ok            = "Polaczenie z internetem OK."
        net_fail          = "Brak polaczenia z GitHub. Przerwano instalacje."
        omp_installing    = "`nPobieranie i instalacja Oh My Posh..."
        omp_done          = "Oh My Posh zainstalowany!"
        omp_present       = "Oh My Posh juz zainstalowany."
        omp_path_fail     = "oh-my-posh nie jest dostepny w PATH. Sprawdz instalacje."
        theme_downloading = "`nPobieranie motywu Oh My Posh..."
        theme_saved       = "Motyw zapisany: {0}"
        ti_checking       = "`nSprawdzanie modulu Terminal-Icons..."
        ti_done           = "Terminal-Icons zainstalowany!"
        ti_present        = "Terminal-Icons juz zainstalowany."
        font_prompt       = "`nCzy chcesz zainstalowac czcionke Cousine Nerd Font? (y/n)"
        font_downloading  = "Pobieranie Cousine Nerd Font {0}..."
        font_done         = "Czcionka Cousine Nerd Font zainstalowana!"
        font_fail         = "Nie udalo sie zainstalowac czcionki: {0}"
        font_skipped      = "Pominieto instalacje czcionki."
        profile_created   = "Utworzono plik profilu: {0}"
        profile_present   = "Profil PowerShell juz zawiera konfiguracje Oh My Posh."
        profile_updating  = "`nKonfiguracja PowerShell profile..."
        profile_updated   = "Profil PowerShell zaktualizowany!"
        summary_title     = "Instalacja zakonczona pomyslnie!"
        summary_next      = "Co dalej?"
        summary_step1     = "  1) Zamknij i otworz nowe okno PowerShell 7 (pwsh)"
        summary_step2     = "  2) Jesli zainstalowano czcionke - w ustawieniach terminala"
        summary_step2b    = "     ustaw czcionke: Cousine Nerd Font"
        summary_theme_at  = "Motyw zapisany w:"
        summary_profile_at= "Profil PowerShell:"
    }
    en = @{
        starting          = "`n[setup] Starting Oh My Posh Installer..."
        ps7_missing       = "[warning] PowerShell 7 or higher is required!"
        ps7_downloading   = "Downloading PowerShell 7..."
        ps7_installing    = "Installing PowerShell 7 ({0})..."
        ps7_done          = "PowerShell 7 installed. Restart your terminal as pwsh!"
        ps7_fail          = "Failed to install PowerShell 7: {0}"
        ps7_manual        = "Install manually: https://aka.ms/install-powershell"
        ps7_ok            = "PowerShell {0} detected."
        net_checking      = "`nChecking internet connection..."
        net_ok            = "Internet connection OK."
        net_fail          = "Unable to reach GitHub. Installation aborted."
        omp_installing    = "`nDownloading and installing Oh My Posh..."
        omp_done          = "Oh My Posh installed!"
        omp_present       = "Oh My Posh already installed."
        omp_path_fail     = "oh-my-posh is not available in PATH. Check the installation."
        theme_downloading = "`nDownloading Oh My Posh theme..."
        theme_saved       = "Theme saved: {0}"
        ti_checking       = "`nChecking Terminal-Icons module..."
        ti_done           = "Terminal-Icons installed!"
        ti_present        = "Terminal-Icons already installed."
        font_prompt       = "`nDo you want to install the Cousine Nerd Font? (y/n)"
        font_downloading  = "Downloading Cousine Nerd Font {0}..."
        font_done         = "Cousine Nerd Font installed!"
        font_fail         = "Failed to install font: {0}"
        font_skipped      = "Font installation skipped."
        profile_created   = "Created profile file: {0}"
        profile_present   = "PowerShell profile already contains Oh My Posh config."
        profile_updating  = "`nConfiguring PowerShell profile..."
        profile_updated   = "PowerShell profile updated!"
        summary_title     = "Installation completed successfully!"
        summary_next      = "What's next?"
        summary_step1     = "  1) Close and reopen a PowerShell 7 (pwsh) window"
        summary_step2     = "  2) If you installed the font - in your terminal settings"
        summary_step2b    = "     set the font to: Cousine Nerd Font"
        summary_theme_at  = "Theme saved at:"
        summary_profile_at= "PowerShell profile:"
    }
}
$S = $Strings[$Lang]

function Say([string]$Key, [string[]]$FormatArgs, [string]$Color = "White") {
    $text = $S[$Key]
    if ($FormatArgs) { $text = $text -f $FormatArgs }
    Write-Host $text -ForegroundColor $Color
}

Say "starting" -Color Cyan

# --------------------------
# 1. PowerShell 7+ check/install
# --------------------------
function Ensure-PS7 {
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Say "ps7_missing" -Color Yellow
        Say "ps7_downloading" -Color Gray
        try {
            $ps7Msi = "$env:TEMP\PowerShell-7.msi"
            $latestUrl = "https://github.com/PowerShell/PowerShell/releases/latest"
            $response = Invoke-WebRequest $latestUrl -UseBasicParsing -MaximumRedirection 5
            $version = $response.BaseResponse.RequestMessage.RequestUri.Segments[-1].TrimStart('v')
            $msiUrl = "https://github.com/PowerShell/PowerShell/releases/download/v$version/PowerShell-$version-win-x64.msi"

            Invoke-WebRequest $msiUrl -OutFile $ps7Msi -UseBasicParsing
            Say "ps7_installing" @($version) -Color Cyan
            Start-Process msiexec.exe -ArgumentList "/i `"$ps7Msi`" /qn /norestart" -Wait
            Remove-Item $ps7Msi -Force
            Say "ps7_done" -Color Green
            exit
        } catch {
            Say "ps7_fail" @($_) -Color Red
            Say "ps7_manual" -Color Yellow
            exit
        }
    } else {
        Say "ps7_ok" @($PSVersionTable.PSVersion) -Color Green
    }
}
Ensure-PS7

# --------------------------
# 2. Internet connectivity check
# --------------------------
Say "net_checking" -Color Gray
try {
    $null = Invoke-WebRequest "https://github.com" -UseBasicParsing -TimeoutSec 5
    Say "net_ok" -Color Green
} catch {
    Say "net_fail" -Color Red
    exit
}

# --------------------------
# 3. Oh My Posh install
# --------------------------
$ompExe = "$env:LOCALAPPDATA\Programs\oh-my-posh\bin\oh-my-posh.exe"
if (-not (Test-Path $ompExe)) {
    Say "omp_installing"
    winget install JanDeDobbeleer.OhMyPosh -s winget --silent --accept-package-agreements --accept-source-agreements
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "User")
    Say "omp_done" -Color Green
} else {
    Say "omp_present" -Color Gray
}

if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    if (Test-Path $ompExe) {
        $env:PATH += ";$env:LOCALAPPDATA\Programs\oh-my-posh\bin"
    } else {
        Say "omp_path_fail" -Color Red
        exit
    }
}

# --------------------------
# 4. Theme download
# --------------------------
$themesFolder = "$env:USERPROFILE\Documents\PowerShell\PoshThemes"
if (-not (Test-Path $themesFolder)) {
    New-Item -ItemType Directory -Path $themesFolder -Force | Out-Null
}

$themePath = "$themesFolder\jandedobbeleer.omp.json"
$themeUrl  = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/jandedobbeleer.omp.json"

Say "theme_downloading"
Invoke-WebRequest $themeUrl -OutFile $themePath -UseBasicParsing
Say "theme_saved" @($themePath) -Color Green

# --------------------------
# 5. Terminal-Icons module
# --------------------------
Say "ti_checking"
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser -Force -AllowClobber
    Say "ti_done" -Color Green
} else {
    Say "ti_present" -Color Gray
}

# --------------------------
# 6. Font (optional)
# --------------------------
$fontAnswer = Read-Host $S.font_prompt
if ($fontAnswer -ieq "y") {
    try {
        $nfRelease = Invoke-RestMethod "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"
        $nfVersion = $nfRelease.tag_name
        $fontZipUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/$nfVersion/Cousine.zip"

        Say "font_downloading" @($nfVersion) -Color Gray
        $fontZip = "$env:TEMP\Cousine.zip"
        Invoke-WebRequest $fontZipUrl -OutFile $fontZip -UseBasicParsing
        Expand-Archive $fontZip -DestinationPath "$env:TEMP\Cousine" -Force

        $shell = New-Object -ComObject Shell.Application
        $fontsFolder = $shell.Namespace(0x14)
        Get-ChildItem "$env:TEMP\Cousine" -Include '*.ttf', '*.otf', '*.ttc' -Recurse | ForEach-Object {
            $tempFont = "$env:TEMP\$($_.Name)"
            Copy-Item $_.FullName $tempFont -Force
            $fontsFolder.CopyHere($tempFont, 0x10)
            Remove-Item $tempFont -Force
        }

        Remove-Item "$env:TEMP\Cousine" -Recurse -Force
        Remove-Item $fontZip -Force
        Say "font_done" -Color Green
    } catch {
        Say "font_fail" @($_) -Color Red
    }
} else {
    Say "font_skipped" -Color Yellow
}

# --------------------------
# 7. PowerShell profile update
# --------------------------
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    Say "profile_created" @($PROFILE) -Color Gray
}

if (Select-String -Path $PROFILE -Pattern "### OMP CONFIG START ###" -Quiet) {
    Say "profile_present" -Color Gray
} else {
    Say "profile_updating" -Color Gray

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
    Say "profile_updated" -Color Green
}

# --------------------------
# 8. Summary
# --------------------------
Write-Host "`n------------------------------------------------------------" -ForegroundColor White
Say "summary_title" -Color Green
Say "summary_next" -Color Cyan
Say "summary_step1" -Color Yellow
Say "summary_step2" -Color Yellow
Say "summary_step2b" -Color Yellow
Write-Host ""
Say "summary_theme_at" -Color Gray
Write-Host "  $themePath" -ForegroundColor White
Say "summary_profile_at" -Color Gray
Write-Host "  $PROFILE" -ForegroundColor White
Write-Host "------------------------------------------------------------`n" -ForegroundColor White
