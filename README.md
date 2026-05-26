# ⚡ Oh My Posh PowerShell Auto-Installer

<img width="1448" height="839" alt="Oh My Posh preview" src="https://github.com/user-attachments/assets/7d19af98-fbba-4776-bb6a-9b699fa3d422" />

Easily install [Oh My Posh](https://ohmyposh.dev), optional Nerd Fonts, and the `Terminal-Icons` module with a single script!

---

## 🚀 Features

- ✅ Auto-detects PowerShell version
- 🎨 Installs the `jandedobbeleer` Oh My Posh theme
- 🖋️ Optional Cousine Nerd Font installation (latest version)
- 📦 Installs and configures the `Terminal-Icons` module
- 📝 Automatically updates your PowerShell `$PROFILE`
- 🌐 Internet connection check & error handling

---

## 🖥️ Requirements

- Windows 10 or Windows 11
- PowerShell 7.x or newer (`pwsh`)
- `winget` (included in Windows 10 21H1+ and Windows 11)

---

## 📥 Installation

### ⚠️ Step 1 — Install PowerShell 7 (if needed)

Check your current version:
```powershell
$PSVersionTable.PSVersion
```

If the Major version is below `7`, install PowerShell 7 first.

**Option 1 — Automatic (run in Windows PowerShell 5.1):**
```powershell
winget install Microsoft.PowerShell --silent --accept-package-agreements
```

**Option 2 — Manual install (recommended):**

Go to the official Microsoft guide and download the latest x64 MSI installer:
```
https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows
```

After installation, close your terminal and open **PowerShell 7** (`pwsh`).

---

### 🚀 Step 2 — Run the installer

Open **PowerShell 7** and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
irm https://raw.githubusercontent.com/Hiheys/Oh-my-posh-AutoInstaller/main/Install-pl-V3.ps1 | iex
```

The script will:
1. Verify PowerShell 7 is running
2. Check internet connectivity
3. Install Oh My Posh via `winget`
4. Download the `jandedobbeleer` theme
5. Optionally install Cousine Nerd Font
6. Install the `Terminal-Icons` module
7. Update your `$PROFILE` automatically

---

### 🖋️ Step 3 — Set the font in your terminal (optional)

If you installed Cousine Nerd Font, set it in Windows Terminal:

1. Open Windows Terminal → **Settings** (`Ctrl+,`)
2. Go to **Profiles → PowerShell**
3. Under **Appearance**, set font to `Cousine Nerd Font`
4. Save and restart the terminal

---

## 🔧 Customization

### Changing the theme

All Oh My Posh themes are available at:
```
https://ohmyposh.dev/docs/themes
```

To change the theme, edit your `$PROFILE`:
```powershell
notepad $PROFILE
```

Replace the `--config` path with any theme from your themes folder:
```powershell
oh-my-posh init pwsh --config "$env:USERPROFILE\Documents\PowerShell\PoshThemes\YOUR_THEME.omp.json" | Invoke-Expression
```

Or browse and download more themes:
```powershell
Get-PoshThemes
```

---

## ❓ Troubleshooting

**CONFIG NOT FOUND error**

The theme file path in `$PROFILE` is incorrect or the file is missing. Run:
```powershell
Test-Path "$env:USERPROFILE\Documents\PowerShell\PoshThemes\jandedobbeleer.omp.json"
```
If it returns `False`, re-run the installer.

---

**Icons display as boxes or question marks**

You need a Nerd Font. Re-run the installer and choose `y` when asked about Cousine Nerd Font, then set it in your terminal settings (see Step 3).

---

**`oh-my-posh` not recognized after install**

Restart your terminal or reload the profile:
```powershell
. $PROFILE
```

---

**`winget` not found**

Update the [App Installer](https://apps.microsoft.com/detail/9NBLGGH4NNS1) from the Microsoft Store, or install PowerShell 7 manually (Option 2 above).

---

## 🗑️ Uninstall

```powershell
# Remove Oh My Posh
winget uninstall JanDeDobbeleer.OhMyPosh

# Remove Terminal-Icons module
Uninstall-Module Terminal-Icons

# Remove theme folder
Remove-Item "$env:USERPROFILE\Documents\PowerShell\PoshThemes" -Recurse -Force

# Remove config from $PROFILE
notepad $PROFILE
# Manually delete the lines between ### OMP CONFIG START ### and ### OMP CONFIG END ###
```

---

## 📄 License

MIT — feel free to use, modify, and share.
