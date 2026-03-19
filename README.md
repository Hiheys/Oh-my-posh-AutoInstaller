# ⚡ Oh My Posh PowerShell Auto-Installer
<img width="1448" height="839" alt="image" src="https://github.com/user-attachments/assets/7d19af98-fbba-4776-bb6a-9b699fa3d422" />

Easily install [Oh My Posh](https://ohmyposh.dev), optional Nerd Fonts, and the `Terminal-Icons` module with a single script!

---

## 🚀 Features

- ✅ Auto-detects system architecture
- 🖋️ Optional Cousine Nerd Font installation
- 📦 Installs `Terminal-Icons` module
- 📝 Automatically configures your PowerShell `$PROFILE`
- 🌐 Internet connection check & error handling
- 🖥️ Works with PowerShell 7.x+

---

## 📥 Installation
⚠️ PowerShell 7 Required

This script requires PowerShell 7.x or newer.

If you're using the default Windows PowerShell (5.1), install PowerShell 7 first:

🛠️ Install PowerShell 7
👉 Option 1 (Recommended – automatic)

Run this in Windows PowerShell (5.1):

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest https://aka.ms/win64ps7 -OutFile "$env:TEMP\PowerShell-7.msi"
Start-Process msiexec.exe -ArgumentList "/i `"$env:TEMP\PowerShell-7.msi`" /qn /norestart" -Wait

👉 Option 2 (Manual install)

Go to the official Microsoft guide:
`https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows?view=powershell-7.6`

Download the latest x64 MSI installer

Run the installer and follow the steps

▶️ After installation

Close your current terminal

Open PowerShell 7 (pwsh)

Run the installer below

🚀 Quick Install
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
iwr -useb https://raw.github.com/Hiheys/Oh-my-posh-AutoInstaller/main/Install-en.ps1 | iex
```

💡 Tip

You can check your PowerShell version with:
```powershell
$PSVersionTable.PSVersion
```
