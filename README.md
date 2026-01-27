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

### Quick install (PowerShell 7+ required):

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
iwr -useb https://raw.github.com/Hiheys/Oh-my-posh-AutoInstaller/main/Install-en.ps1 | iex
