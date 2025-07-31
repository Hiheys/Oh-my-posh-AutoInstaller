<#
    Auto Installer for Oh My Posh with Fonts & Terminal-Icons
    Author: YourGitHubUsername
#>

Write-Host "`n[🔧] Starting Oh My Posh Installer..." -ForegroundColor Cyan

# PowerShell 7+ required
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "[⚠️] PowerShell 7 or higher is required!" -ForegroundColor Yellow
    Write-Host "📥 Download here: https://github.com/PowerShell/PowerShell" -ForegroundColor Yellow
    exit
}

# Check GitHub connectivity
Write-Host "`n🌐 Checking connection to GitHub..." -ForegroundColor Gray
if (-not (Test-Connection -ComputerName github.com -Count 1 -Quiet)) {
    Write-Host "❌ Unable to reach GitHub. Installation aborted." -ForegroundColor Red
    exit
}

# Detect architecture
$installer = if ([Environment]::Is64BitOperatingSystem) { "posh-windows-amd64.exe" } else { "posh-windows-386.exe" }
$url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/$installer"

# Download Oh My Posh
Write-Host "`n📦 Downloading: $installer..." -ForegroundColor White
$tmpInstaller = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'exe' } -PassThru

try {
    Invoke-WebRequest -Uri $url -OutFile $tmpInstaller -UseBasicParsing -ErrorAction Stop
    Write-Host "✅ Successfully downloaded!" -ForegroundColor Green
} catch {
    Write-Host "❌ Download failed: $_" -ForegroundColor Red
    exit
}

# Run installer
Write-Host "`n🚀 Installing Oh My Posh..." -ForegroundColor Cyan
& $tmpInstaller /VERYSILENT "/CURRENTUSER"
Remove-Item $tmpInstaller -Force

# Font prompt
$fontAnswer = Read-Host "`n🖋️ Do you want to install the Cousine NFM font? (y/n)"
if ($fontAnswer -ieq "y") {
    Write-Host "`n📦 Downloading Cousine Nerd Font..."
    $tmpZip = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'zip' } -PassThru
    $fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Cousine.zip"

    try {
        Invoke-WebRequest -Uri $fontUrl -OutFile $tmpZip -UseBasicParsing -ErrorAction Stop
        Write-Host "✅ Font downloaded!" -ForegroundColor Green

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

        Write-Host "🖨️ Installing fonts..."
        Install-Fonts $fontFolder
        Remove-Item $fontFolder -Recurse -Force
        Remove-Item $tmpZip -Force
        Write-Host "✅ Cousine NFM installed!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Font installation error: $_" -ForegroundColor Red
    }
} else {
    Write-Host "⏭️ Font installation skipped." -ForegroundColor Yellow
}

# Terminal-Icons module
Write-Host "`n📦 Installing Terminal-Icons module..."
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    try {
        Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
        Write-Host "✅ Terminal-Icons installed!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Terminal-Icons installation failed: $_" -ForegroundColor Red
    }
} else {
    Write-Host "✔️ Terminal-Icons already installed." -ForegroundColor Gray
}

# Profile modification
if (-not (Select-String -Path $PROFILE -Pattern "Generated - START" -Quiet)) {
    Write-Host "`n📝 Updating PowerShell profile: $PROFILE" -ForegroundColor Gray
    Add-Content -Path $PROFILE -Value "`n### Generated - START ###"
    Add-Content -Path $PROFILE -Value 'if ($PSVersionTable.PSVersion.Major -ge 7) {'
    Add-Content -Path $PROFILE -Value '    Import-Module Terminal-Icons'
    Add-Content -Path $PROFILE -Value '    oh-my-posh init pwsh | Invoke-Expression'
    Add-Content -Path $PROFILE -Value '}'
    Add-Content -Path $PROFILE -Value "### Generated - END ###"
    Write-Host "✅ PowerShell profile updated." -ForegroundColor Green
} else {
    Write-Host "✔️ PowerShell profile already contains configuration." -ForegroundColor Gray
}

# Final summary
Write-Host "`n------------------------------------------------------------" -ForegroundColor White
Write-Host "✅ Installation complete!" -ForegroundColor Green
Write-Host "📌 Next steps:" -ForegroundColor Cyan
Write-Host "1) Restart PowerShell 7" -ForegroundColor Yellow
Write-Host "2) Open terminal settings" -ForegroundColor Yellow
Write-Host "3) Select font: Cousine NFM" -ForegroundColor Yellow
Write-Host "------------------------------------------------------------" -ForegroundColor White
