# ⚡ Oh My Posh PowerShell Auto-Installer

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

### Quick install (PowerShell 7+ required):

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
iwr -useb https://raw.github.com/Hiheys/Oh-my-posh-AutoInstaller/main/Install-en.ps1 | iex
