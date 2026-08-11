# ⚡ Oh My Posh PowerShell Auto-Installer

<img width="1668" height="852" alt="image" src="https://github.com/user-attachments/assets/bfd0b2ea-98bf-4e04-9ea9-db5db0874d3b" />

Easily install [Oh My Posh](https://ohmyposh.dev), optional Nerd Fonts, and the `Terminal-Icons` module with a single script — available in **Polish and English**, selectable at runtime.

---

## 🚀 Features

- 🌍 Interactive language selection (PL / EN) — no more separate script files per language
- ✅ Auto-detects and installs PowerShell 7 if missing
- 🎨 Installs the `jandedobbeleer` Oh My Posh theme
- 🖋️ Optional Cousine Nerd Font installation (latest version)
- 📦 Installs and configures the `Terminal-Icons` module
- 📝 Automatically updates your PowerShell `$PROFILE`
- 🌐 Internet connection check & error handling

---

## 🖥️ Requirements

- Windows 10 or Windows 11
- PowerShell 7.x or newer (`pwsh`) — the script installs it automatically if it's missing
- `winget` (included in Windows 10 21H1+ and Windows 11)

---

## 📥 Installation

### 🚀 Run the installer

Open **PowerShell** (5.1 or 7 — the script will install PS7 for you if needed) and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
irm https://raw.githubusercontent.com/Hiheys/Oh-my-posh-AutoInstaller/main/Install.ps1 | iex
```

You'll be prompted to choose a language:

```
Select language / Wybierz jezyk:
  [1] Polski
  [2] English
Twoj wybor / Your choice (Enter = en):
```

Pressing **Enter** picks the language matching your system locale automatically.

The script will then:

1. Verify (and install, if needed) PowerShell 7
2. Check internet connectivity
3. Install Oh My Posh via `winget`
4. Download the `jandedobbeleer` theme
5. Optionally install Cousine Nerd Font
6. Install the `Terminal-Icons` module
7. Update your `$PROFILE` automatically

### 🤖 Non-interactive usage

For automation/provisioning, skip the language prompt by setting an environment variable first:

```powershell
$env:OMP_LANG = "en"   # or "pl"
irm https://raw.githubusercontent.com/Hiheys/Oh-my-posh-AutoInstaller/main/Install.ps1 | iex
```

---

### 🖋️ Step 2 — Set the font in your terminal (optional)

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

### Adding another language

All user-facing text lives in a single `$Strings` hashtable near the top of `Install.ps1`. To add a new language:

1. Copy the `en` block inside `$Strings` and rename it (e.g. `de`)
2. Translate each value
3. Add the new option to the language prompt in `Get-InstallerLanguage`

No other part of the script needs to change.

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

You need a Nerd Font. Re-run the installer and choose `y` when asked about Cousine Nerd Font, then set it in your terminal settings (see Step 2 above).

---

**`oh-my-posh` not recognized after install**

Restart your terminal or reload the profile:

```powershell
. $PROFILE
```

---

**`winget` not found**

Update the [App Installer](https://apps.microsoft.com/detail/9NBLGGH4NNS1) from the Microsoft Store.

---

**Wrong language was selected**

Re-run the installer and either pick the other option at the prompt, or set `$env:OMP_LANG` before running (see [Non-interactive usage](#-non-interactive-usage)).

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
